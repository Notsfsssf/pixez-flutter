#include "login_plugin.h"

#include <gdk/gdkkeysyms.h>
#include <webkit2/webkit2.h>
#include <string>

std::string LoginPlugin::name = "com.perol.dev/login";
GtkWindow* LoginPlugin::s_parent_window = nullptr;

namespace {

struct LoginSession;
static LoginSession* s_active_session = nullptr;

struct LoginSession {
  FlMethodCall* method_call = nullptr;
  GtkWidget* dialog = nullptr;
  GtkWidget* web_view = nullptr;
  bool handled = false;

  ~LoginSession() {
    if (method_call != nullptr) {
      g_object_unref(method_call);
      method_call = nullptr;
    }
    if (web_view != nullptr) {
      g_signal_handlers_disconnect_by_data(web_view, this);
      webkit_web_view_stop_loading(WEBKIT_WEB_VIEW(web_view));
      web_view = nullptr;
    }
  }

  bool CheckAndHandleRedirect(const gchar* uri) {
    if (uri == nullptr || handled) {
      return false;
    }
    std::string url(uri);

    // Pixiv scheme: pixiv://account/login?code=...
    if (url.rfind("pixiv://", 0) == 0) {
      FinishWithResult(url);
      return true;
    }

    // HTTPS callback: https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback?...
    if (url.find("/web/v1/users/auth/pixiv/callback") != std::string::npos) {
      size_t qpos = url.find('?');
      std::string query = (qpos != std::string::npos) ? url.substr(qpos) : "";
      std::string pixiv_uri = "pixiv://account/login" + query;
      FinishWithResult(pixiv_uri);
      return true;
    }

    return false;
  }

  void FinishWithResult(const std::string& result) {
    if (handled) return;
    handled = true;
    if (s_active_session == this) {
      s_active_session = nullptr;
    }
    if (web_view != nullptr) {
      g_signal_handlers_disconnect_by_data(web_view, this);
      webkit_web_view_stop_loading(WEBKIT_WEB_VIEW(web_view));
      web_view = nullptr;
    }
    if (method_call != nullptr) {
      g_autoptr(FlValue) val = fl_value_new_string(result.c_str());
      fl_method_call_respond_success(method_call, val, nullptr);
      g_object_unref(method_call);
      method_call = nullptr;
    }
    if (dialog != nullptr) {
      GtkWidget* win = dialog;
      dialog = nullptr;
      // Immediately hide the window so user cannot interact further
      gtk_widget_hide(win);
      // Retain reference to prevent premature freeing before idle dispatch
      g_object_ref(win);
      g_idle_add_full(
          G_PRIORITY_DEFAULT_IDLE,
          G_SOURCE_FUNC(+[](gpointer data) -> gboolean {
            GtkWidget* w = GTK_WIDGET(data);
            gtk_widget_destroy(w);
            g_object_unref(w);
            return G_SOURCE_REMOVE;
          }),
          win,
          nullptr);
    }
  }

  void FinishWithNull() {
    if (handled) return;
    handled = true;
    if (s_active_session == this) {
      s_active_session = nullptr;
    }
    if (web_view != nullptr) {
      g_signal_handlers_disconnect_by_data(web_view, this);
      webkit_web_view_stop_loading(WEBKIT_WEB_VIEW(web_view));
      web_view = nullptr;
    }
    if (method_call != nullptr) {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
      g_object_unref(method_call);
      method_call = nullptr;
    }
  }
};

static gboolean on_decide_policy(WebKitWebView* web_view,
                                 WebKitPolicyDecision* decision,
                                 WebKitPolicyDecisionType type,
                                 gpointer user_data) {
  if (type == WEBKIT_POLICY_DECISION_TYPE_NAVIGATION_ACTION) {
    WebKitNavigationPolicyDecision* nav_decision =
        WEBKIT_NAVIGATION_POLICY_DECISION(decision);
    WebKitNavigationAction* action =
        webkit_navigation_policy_decision_get_navigation_action(nav_decision);
    WebKitURIRequest* request = webkit_navigation_action_get_request(action);
    const gchar* uri = webkit_uri_request_get_uri(request);
    LoginSession* session = static_cast<LoginSession*>(user_data);
    if (session != nullptr && session->CheckAndHandleRedirect(uri)) {
      webkit_policy_decision_ignore(decision);
      return TRUE;
    }
  }
  return FALSE;
}

static gboolean on_load_failed(WebKitWebView* web_view,
                               WebKitLoadEvent load_event,
                               const gchar* failing_uri,
                               GError* error,
                               gpointer user_data) {
  if (g_error_matches(error, WEBKIT_NETWORK_ERROR, WEBKIT_NETWORK_ERROR_CANCELLED)) {
    return FALSE;
  }
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr && session->CheckAndHandleRedirect(failing_uri)) {
    return TRUE;
  }
  return FALSE;
}

static void on_uri_changed(GObject* object, GParamSpec* pspec, gpointer user_data) {
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  const gchar* uri = webkit_web_view_get_uri(web_view);
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr) {
    session->CheckAndHandleRedirect(uri);
  }
}

static void on_progress_changed(GObject* object, GParamSpec* pspec, gpointer user_data) {
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  GtkProgressBar* bar = GTK_PROGRESS_BAR(user_data);
  gdouble progress = webkit_web_view_get_estimated_load_progress(web_view);
  gtk_progress_bar_set_fraction(bar, progress);
  if (progress >= 1.0) {
    gtk_widget_hide(GTK_WIDGET(bar));
  } else {
    gtk_widget_show(GTK_WIDGET(bar));
  }
}

static void on_web_view_destroy(GtkWidget* widget, gpointer user_data) {
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr && session->web_view == widget) {
    session->web_view = nullptr;
  }
}

static void on_dialog_destroy(GtkWidget* widget, gpointer user_data) {
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr) {
    session->FinishWithNull();
    delete session;
  }
}

static gboolean on_dialog_key_press(GtkWidget* widget,
                                    GdkEventKey* event,
                                    gpointer user_data) {
  if (event->keyval == GDK_KEY_Escape) {
    gtk_widget_destroy(widget);
    return TRUE;
  }
  return FALSE;
}

}  // namespace

void LoginPlugin::HandleMethodCall(FlMethodChannel* channel,
                                   FlMethodCall* method_call,
                                   gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (strcmp(method, "open") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      fl_method_call_respond_error(
          method_call, "BAD_ARGS", "Expected argument map", nullptr, nullptr);
      return;
    }
    FlValue* url_val = fl_value_lookup_string(args, "url");
    if (url_val == nullptr || fl_value_get_type(url_val) != FL_VALUE_TYPE_STRING) {
      fl_method_call_respond_error(
          method_call, "BAD_ARGS", "Expected 'url' string", nullptr, nullptr);
      return;
    }
    const gchar* url = fl_value_get_string(url_val);
    std::string title = "Pixiv";
    FlValue* title_val = fl_value_lookup_string(args, "title");
    if (title_val != nullptr && fl_value_get_type(title_val) == FL_VALUE_TYPE_STRING) {
      title = fl_value_get_string(title_val);
    }

    if (s_active_session != nullptr) {
      if (s_active_session->dialog != nullptr) {
        gtk_window_present(GTK_WINDOW(s_active_session->dialog));
      }
      fl_method_call_respond_error(
          method_call, "ALREADY_ACTIVE", "Login window is already open", nullptr, nullptr);
      return;
    }

    LoginSession* session = new LoginSession();
    session->method_call = FL_METHOD_CALL(g_object_ref(method_call));
    s_active_session = session;

    // Create modal dialog
    GtkWidget* dialog = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    session->dialog = dialog;
    if (s_parent_window != nullptr) {
      gtk_window_set_transient_for(GTK_WINDOW(dialog), s_parent_window);
      gtk_window_set_destroy_with_parent(GTK_WINDOW(dialog), TRUE);
    }
    gtk_window_set_modal(GTK_WINDOW(dialog), TRUE);
    gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_CENTER_ON_PARENT);
    gtk_window_set_default_size(GTK_WINDOW(dialog), 480, 700);

    // Header bar
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_header_bar_set_title(header_bar, title.c_str());

    GtkWidget* back_btn =
        gtk_button_new_from_icon_name("go-previous-symbolic", GTK_ICON_SIZE_BUTTON);
    gtk_header_bar_pack_start(header_bar, back_btn);

    GtkWidget* reload_btn =
        gtk_button_new_from_icon_name("view-refresh-symbolic", GTK_ICON_SIZE_BUTTON);
    gtk_header_bar_pack_start(header_bar, reload_btn);
    gtk_window_set_titlebar(GTK_WINDOW(dialog), GTK_WIDGET(header_bar));

    // Content container
    GtkWidget* box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    GtkWidget* progress_bar = gtk_progress_bar_new();
    gtk_box_pack_start(GTK_BOX(box), progress_bar, FALSE, FALSE, 0);

    // Use ephemeral WebKitWebContext to guarantee clean session per login and multi-account support
    g_autoptr(WebKitWebContext) context = webkit_web_context_new_ephemeral();
    GtkWidget* web_view = webkit_web_view_new_with_context(context);
    session->web_view = web_view;

    WebKitSettings* settings =
        webkit_web_view_get_settings(WEBKIT_WEB_VIEW(web_view));
    webkit_settings_set_enable_javascript(settings, TRUE);
    webkit_settings_set_enable_smooth_scrolling(settings, TRUE);
    webkit_settings_set_user_agent(
        settings,
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/128.0.0.0 Safari/537.36");

    g_signal_connect_swapped(
        back_btn, "clicked", G_CALLBACK(webkit_web_view_go_back), web_view);
    g_signal_connect_swapped(
        reload_btn, "clicked", G_CALLBACK(webkit_web_view_reload), web_view);
    g_signal_connect(
        web_view, "decide-policy", G_CALLBACK(on_decide_policy), session);
    g_signal_connect(
        web_view, "load-failed", G_CALLBACK(on_load_failed), session);
    g_signal_connect(
        web_view, "notify::uri", G_CALLBACK(on_uri_changed), session);
    g_signal_connect_object(
        web_view, "notify::estimated-load-progress",
        G_CALLBACK(on_progress_changed), progress_bar, G_CONNECT_DEFAULT);
    g_signal_connect(
        web_view, "destroy", G_CALLBACK(on_web_view_destroy), session);
    g_signal_connect(
        dialog, "key-press-event", G_CALLBACK(on_dialog_key_press), nullptr);
    g_signal_connect(
        dialog, "destroy", G_CALLBACK(on_dialog_destroy), session);

    gtk_box_pack_start(GTK_BOX(box), web_view, TRUE, TRUE, 0);
    gtk_container_add(GTK_CONTAINER(dialog), box);

    gtk_widget_show_all(dialog);
    webkit_web_view_load_uri(WEBKIT_WEB_VIEW(web_view), url);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void LoginPlugin::Initialize(FlPluginRegistrar* registrar, GtkWindow* window) {
  s_parent_window = window;

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), name.c_str(),
      FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(
      channel, HandleMethodCall, nullptr, nullptr);
}
