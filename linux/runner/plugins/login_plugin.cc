#include "login_plugin.h"

#include <webkit2/webkit2.h>

#include <algorithm>
#include <cmath>
#include <string>

std::string LoginPlugin::name = "com.perol.dev/login";
GtkOverlay* LoginPlugin::s_overlay = nullptr;
FlView* LoginPlugin::s_fl_view = nullptr;
FlMethodChannel* LoginPlugin::s_channel = nullptr;

namespace {

struct LoginSession;
static LoginSession* s_active_session = nullptr;

static double get_double_from_map(FlValue* map, const gchar* key,
                                  double def_val = 0.0) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP)
    return def_val;
  FlValue* val = fl_value_lookup_string(map, key);
  if (val == nullptr) return def_val;
  if (fl_value_get_type(val) == FL_VALUE_TYPE_FLOAT) {
    return fl_value_get_float(val);
  }
  if (fl_value_get_type(val) == FL_VALUE_TYPE_INT) {
    return static_cast<double>(fl_value_get_int(val));
  }
  return def_val;
}

struct LoginSession {
  FlMethodCall* method_call = nullptr;
  GtkWidget* container = nullptr;
  GtkWidget* web_view = nullptr;
  int x = 0;
  int y = 0;
  int width = 0;
  int height = 0;
  bool handled = false;

  ~LoginSession() {
    if (method_call != nullptr) {
      g_object_unref(method_call);
      method_call = nullptr;
    }
    if (web_view != nullptr) {
      g_signal_handlers_disconnect_by_data(web_view, this);
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

    // HTTPS callback:
    // https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback?...
    if (url.find("/web/v1/users/auth/pixiv/callback") != std::string::npos) {
      size_t qpos = url.find('?');
      std::string query = (qpos != std::string::npos) ? url.substr(qpos) : "";
      std::string pixiv_uri = "pixiv://account/login" + query;
      FinishWithResult(pixiv_uri);
      return true;
    }

    return false;
  }

  void CleanupContainer() {
    if (container != nullptr) {
      GtkWidget* c = container;
      container = nullptr;
      web_view = nullptr;
      gtk_widget_hide(c);
      g_object_ref(c);
      g_idle_add_full(G_PRIORITY_DEFAULT_IDLE,
                      G_SOURCE_FUNC(+[](gpointer data) -> gboolean {
                        GtkWidget* widget = GTK_WIDGET(data);
                        if (GTK_IS_WIDGET(widget)) {
                          GtkWidget* parent = gtk_widget_get_parent(widget);
                          if (parent != nullptr && GTK_IS_CONTAINER(parent)) {
                            gtk_container_remove(GTK_CONTAINER(parent), widget);
                          }
                          gtk_widget_destroy(widget);
                        }
                        g_object_unref(widget);
                        return G_SOURCE_REMOVE;
                      }),
                      c, nullptr);
    }
    if (LoginPlugin::s_fl_view != nullptr) {
      gtk_widget_grab_focus(GTK_WIDGET(LoginPlugin::s_fl_view));
    }
    if (LoginPlugin::s_overlay != nullptr) {
      gtk_widget_queue_resize(GTK_WIDGET(LoginPlugin::s_overlay));
    }
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
    }
    if (method_call != nullptr) {
      g_autoptr(FlValue) val = fl_value_new_string(result.c_str());
      fl_method_call_respond_success(method_call, val, nullptr);
      g_object_unref(method_call);
      method_call = nullptr;
    }
    CleanupContainer();
    ScheduleDelete();
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
    }
    if (method_call != nullptr) {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
      g_object_unref(method_call);
      method_call = nullptr;
    }
    CleanupContainer();
    ScheduleDelete();
  }

  void ScheduleDelete() {
    g_idle_add_full(G_PRIORITY_DEFAULT_IDLE,
                    G_SOURCE_FUNC(+[](gpointer data) -> gboolean {
                      LoginSession* s = static_cast<LoginSession*>(data);
                      delete s;
                      return G_SOURCE_REMOVE;
                    }),
                    this, nullptr);
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
                               const gchar* failing_uri, GError* error,
                               gpointer user_data) {
  if (g_error_matches(error, WEBKIT_NETWORK_ERROR,
                      WEBKIT_NETWORK_ERROR_CANCELLED)) {
    return FALSE;
  }
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr && session->CheckAndHandleRedirect(failing_uri)) {
    return TRUE;
  }
  return FALSE;
}

static void on_uri_changed(GObject* object, GParamSpec* pspec,
                           gpointer user_data) {
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  const gchar* uri = webkit_web_view_get_uri(web_view);
  std::string uri_str = (uri != nullptr) ? uri : "";
  LoginSession* session = static_cast<LoginSession*>(user_data);
  if (session != nullptr && !uri_str.empty()) {
    session->CheckAndHandleRedirect(uri_str.c_str());
  }
  if (!uri_str.empty() && LoginPlugin::s_channel != nullptr) {
    g_autoptr(FlValue) val = fl_value_new_string(uri_str.c_str());
    fl_method_channel_invoke_method(LoginPlugin::s_channel, "onUrlChanged", val,
                                    nullptr, nullptr, nullptr);
  }
}

static void on_progress_changed(GObject* object, GParamSpec* pspec,
                                gpointer user_data) {
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  gdouble progress = webkit_web_view_get_estimated_load_progress(web_view);
  if (LoginPlugin::s_channel != nullptr) {
    g_autoptr(FlValue) val = fl_value_new_float(progress);
    fl_method_channel_invoke_method(LoginPlugin::s_channel, "onProgress", val,
                                    nullptr, nullptr, nullptr);
  }
}

static void on_title_changed(GObject* object, GParamSpec* pspec,
                             gpointer user_data) {
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  const gchar* title = webkit_web_view_get_title(web_view);
  if (title != nullptr && LoginPlugin::s_channel != nullptr) {
    g_autoptr(FlValue) val = fl_value_new_string(title);
    fl_method_channel_invoke_method(LoginPlugin::s_channel, "onTitle", val,
                                    nullptr, nullptr, nullptr);
  }
}

static GtkWidget* on_create_web_view(WebKitWebView* web_view,
                                     WebKitNavigationAction* action,
                                     gpointer user_data) {
  WebKitURIRequest* request = webkit_navigation_action_get_request(action);
  const gchar* uri = webkit_uri_request_get_uri(request);
  if (uri != nullptr) {
    webkit_web_view_load_uri(web_view, uri);
  }
  return nullptr;
}

}  // namespace

void LoginPlugin::HandleMethodCall(FlMethodChannel* channel,
                                   FlMethodCall* method_call,
                                   gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "open") == 0) {
    if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      fl_method_call_respond_error(method_call, "BAD_ARGS",
                                   "Expected argument map", nullptr, nullptr);
      return;
    }
    FlValue* url_val = fl_value_lookup_string(args, "url");
    if (url_val == nullptr ||
        fl_value_get_type(url_val) != FL_VALUE_TYPE_STRING) {
      fl_method_call_respond_error(method_call, "BAD_ARGS",
                                   "Expected 'url' string", nullptr, nullptr);
      return;
    }
    if (LoginPlugin::s_overlay == nullptr) {
      fl_method_call_respond_error(method_call, "NO_OVERLAY",
                                   "GtkOverlay not initialized", nullptr,
                                   nullptr);
      return;
    }

    if (s_active_session != nullptr) {
      s_active_session->FinishWithNull();
    }

    const gchar* url = fl_value_get_string(url_val);
    LoginSession* session = new LoginSession();
    session->method_call = FL_METHOD_CALL(g_object_ref(method_call));
    s_active_session = session;

    double x = get_double_from_map(args, "x", 0.0);
    double y = get_double_from_map(args, "y", 0.0);
    double width = get_double_from_map(args, "width", 0.0);
    double height = get_double_from_map(args, "height", 0.0);

    session->x = static_cast<int>(std::round(x));
    session->y = static_cast<int>(std::round(y));
    session->width = static_cast<int>(std::round(width));
    session->height = static_cast<int>(std::round(height));

    session->container = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);

    g_autoptr(WebKitWebContext) context = webkit_web_context_new_ephemeral();
    GtkWidget* web_view = webkit_web_view_new_with_context(context);
    session->web_view = web_view;

    WebKitSettings* settings =
        webkit_web_view_get_settings(WEBKIT_WEB_VIEW(web_view));
    webkit_settings_set_enable_javascript(settings, TRUE);
    webkit_settings_set_enable_smooth_scrolling(settings, TRUE);
    webkit_settings_set_enable_developer_extras(settings, TRUE);
    webkit_settings_set_user_agent(settings,
                                   "Mozilla/5.0 (X11; Linux x86_64) "
                                   "AppleWebKit/537.36 (KHTML, like Gecko) "
                                   "Chrome/128.0.0.0 Safari/537.36");

    g_signal_connect(web_view, "decide-policy", G_CALLBACK(on_decide_policy),
                     session);
    g_signal_connect(web_view, "load-failed", G_CALLBACK(on_load_failed),
                     session);
    g_signal_connect(web_view, "notify::uri", G_CALLBACK(on_uri_changed),
                     session);
    g_signal_connect(web_view, "notify::estimated-load-progress",
                     G_CALLBACK(on_progress_changed), nullptr);
    g_signal_connect(web_view, "notify::title", G_CALLBACK(on_title_changed),
                     nullptr);
    g_signal_connect(web_view, "create", G_CALLBACK(on_create_web_view),
                     nullptr);

    gtk_box_pack_start(GTK_BOX(session->container), web_view, TRUE, TRUE, 0);
    gtk_widget_show_all(session->container);

    gtk_overlay_add_overlay(LoginPlugin::s_overlay, session->container);
    gtk_overlay_set_overlay_pass_through(LoginPlugin::s_overlay,
                                         session->container, FALSE);
    gtk_widget_queue_resize(GTK_WIDGET(LoginPlugin::s_overlay));
    gtk_widget_grab_focus(web_view);

    webkit_web_view_load_uri(WEBKIT_WEB_VIEW(web_view), url);
  } else if (strcmp(method, "updateBounds") == 0) {
    if (s_active_session != nullptr && args != nullptr &&
        fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      double x = get_double_from_map(args, "x", s_active_session->x);
      double y = get_double_from_map(args, "y", s_active_session->y);
      double width =
          get_double_from_map(args, "width", s_active_session->width);
      double height =
          get_double_from_map(args, "height", s_active_session->height);
      s_active_session->x = static_cast<int>(std::round(x));
      s_active_session->y = static_cast<int>(std::round(y));
      s_active_session->width = static_cast<int>(std::round(width));
      s_active_session->height = static_cast<int>(std::round(height));

      FlValue* vis_val = fl_value_lookup_string(args, "visible");
      bool visible = true;
      if (vis_val != nullptr &&
          fl_value_get_type(vis_val) == FL_VALUE_TYPE_BOOL) {
        visible = fl_value_get_bool(vis_val);
      }

      if (s_active_session->container != nullptr) {
        if (visible) {
          gtk_widget_show(s_active_session->container);
        } else {
          gtk_widget_hide(s_active_session->container);
        }
      }
      if (LoginPlugin::s_overlay != nullptr) {
        gtk_widget_queue_resize(GTK_WIDGET(LoginPlugin::s_overlay));
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else if (strcmp(method, "close") == 0) {
    if (s_active_session != nullptr) {
      s_active_session->FinishWithNull();
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else if (strcmp(method, "goBack") == 0) {
    if (s_active_session != nullptr && s_active_session->web_view != nullptr) {
      webkit_web_view_go_back(WEBKIT_WEB_VIEW(s_active_session->web_view));
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else if (strcmp(method, "reload") == 0) {
    if (s_active_session != nullptr && s_active_session->web_view != nullptr) {
      webkit_web_view_reload(WEBKIT_WEB_VIEW(s_active_session->web_view));
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void LoginPlugin::Initialize(FlPluginRegistrar* registrar, GtkOverlay* overlay,
                             FlView* view) {
  s_overlay = overlay;
  s_fl_view = view;

  g_signal_connect(
      overlay, "get-child-position",
      G_CALLBACK(+[](GtkOverlay* ov, GtkWidget* widget, GtkAllocation* alloc,
                     gpointer user_data) -> gboolean {
        if (s_active_session != nullptr &&
            widget == s_active_session->container) {
          if (s_active_session->width > 0 && s_active_session->height > 0) {
            alloc->x = s_active_session->x;
            alloc->y = s_active_session->y;
            alloc->width = s_active_session->width;
            alloc->height = s_active_session->height;
          } else {
            GtkAllocation ov_alloc;
            gtk_widget_get_allocation(GTK_WIDGET(ov), &ov_alloc);
            alloc->x = 0;
            alloc->y = 0;
            alloc->width = std::max(1, ov_alloc.width);
            alloc->height = std::max(1, ov_alloc.height);
          }
          return TRUE;
        }
        return FALSE;
      }),
      nullptr);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  s_channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            name.c_str(), FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(s_channel, HandleMethodCall,
                                            nullptr, nullptr);
}
