#include "document_plugin.h"
#include "../settings.h"
#include "../utils.h"

#include <algorithm>
#include <gio/gio.h>
#include <string.h>
#include <vector>

std::string Document::name = "com.perol.dev/save";
std::string Document::savedFolderToken = "SavedFolderToken";
std::string Document::s_pictures_folder = "";
GtkWindow* Document::s_parent_window = nullptr;

void Document::Initialize(FlPluginRegistrar* registrar, GtkWindow* window) {
  s_parent_window = window;
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger, name.c_str(), FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, HandleMethodCall, nullptr, nullptr);
}

std::string Document::GetPicturesFolder() {
  if (!s_pictures_folder.empty() && g_file_test(s_pictures_folder.c_str(), G_FILE_TEST_IS_DIR)) {
    return s_pictures_folder;
  }

  std::string saved = Settings::TryGetValue(savedFolderToken);
  if (!saved.empty() && g_file_test(saved.c_str(), G_FILE_TEST_IS_DIR)) {
    s_pictures_folder = saved;
    return s_pictures_folder;
  }

  std::string pictures_base = Utils::GetPicturesDirectory();
  g_autofree gchar* full_path = g_build_filename(pictures_base.c_str(), "PixEz", nullptr);
  g_mkdir_with_parents(full_path, 0755);
  s_pictures_folder = full_path;
  return s_pictures_folder;
}

bool Document::BuildDestinationPath(const std::string& file_name,
                                    std::string& out_path) {
  if (file_name.empty()) return false;

  std::string rel_name = file_name;
  // Convert Windows-style backslashes to forward slashes for Linux filesystem.
  std::replace(rel_name.begin(), rel_name.end(), '\\', '/');

  // Strip leading slashes to avoid g_build_filename discarding base_dir.
  while (!rel_name.empty() && rel_name.front() == '/') {
    rel_name.erase(0, 1);
  }
  if (rel_name.empty()) return false;

  std::string base_dir = GetPicturesFolder();
  g_autofree gchar* full_path =
      g_build_filename(base_dir.c_str(), rel_name.c_str(), nullptr);
  g_autofree gchar* canonical_base =
      g_canonicalize_filename(base_dir.c_str(), nullptr);
  g_autofree gchar* canonical_full =
      g_canonicalize_filename(full_path, nullptr);

  // Check directory traversal boundary. Target must be a descendant of base_dir,
  // excluding base_dir itself or sibling directories with matching prefixes.
  if (!g_str_has_prefix(canonical_full, canonical_base)) {
    return false;
  }

  size_t base_len = strlen(canonical_base);
  if (strcmp(canonical_base, "/") == 0) {
    if (canonical_full[0] != '/' || canonical_full[1] == '\0') {
      return false;
    }
  } else {
    if (canonical_full[base_len] != G_DIR_SEPARATOR || canonical_full[base_len + 1] == '\0') {
      return false;
    }
  }

  out_path = canonical_full;
  return true;
}

bool Document::Save(const uint8_t* data, size_t length, const std::string& full_path) {
  g_autofree gchar* parent_dir = g_path_get_dirname(full_path.c_str());
  g_mkdir_with_parents(parent_dir, 0755);

  g_autoptr(GError) error = nullptr;
  const gchar* content_data = (data != nullptr) ? reinterpret_cast<const gchar*>(data) : "";
  gboolean ok = g_file_set_contents(full_path.c_str(), content_data, length, &error);
  if (!ok) {
    g_warning("Save failed to write to '%s': %s",
              full_path.c_str(), error ? error->message : "unknown error");
    return false;
  }
  return true;
}

bool Document::SaveFromPath(const std::string& source_path, const std::string& full_path) {
  if (source_path == full_path) {
    return true;
  }
  if (!g_file_test(source_path.c_str(), G_FILE_TEST_IS_REGULAR)) {
    g_warning("SaveFromPath failed: source file does not exist or is not a regular file: %s",
              source_path.c_str());
    return false;
  }

  g_autofree gchar* parent_dir = g_path_get_dirname(full_path.c_str());
  g_mkdir_with_parents(parent_dir, 0755);

  g_autoptr(GFile) src = g_file_new_for_path(source_path.c_str());
  g_autoptr(GFile) dst = g_file_new_for_path(full_path.c_str());
  g_autoptr(GError) error = nullptr;
  gboolean ok = g_file_copy(src, dst, G_FILE_COPY_OVERWRITE, nullptr, nullptr, nullptr, &error);
  if (!ok) {
    g_warning("SaveFromPath failed to copy from '%s' to '%s': %s",
              source_path.c_str(), full_path.c_str(),
              error ? error->message : "unknown error");
    return false;
  }
  return true;
}

bool Document::OpenSave(const uint8_t* data, size_t length, const std::string& file_name, GtkWindow* window) {
  GtkFileChooserNative* native = gtk_file_chooser_native_new(
      "Save File",
      window,
      GTK_FILE_CHOOSER_ACTION_SAVE,
      "_Save",
      "_Cancel");
  gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(native), TRUE);
  std::string current_dir = GetPicturesFolder();
  gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(native), current_dir.c_str());

  g_autofree gchar* basename = g_path_get_basename(file_name.c_str());
  gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER(native), basename);

  bool success = false;
  gint res = gtk_native_dialog_run(GTK_NATIVE_DIALOG(native));
  if (res == GTK_RESPONSE_ACCEPT) {
    g_autofree gchar* filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(native));
    if (filename != nullptr) {
      g_autoptr(GError) error = nullptr;
      const gchar* content_data = (data != nullptr) ? reinterpret_cast<const gchar*>(data) : "";
      success = g_file_set_contents(filename, content_data, length, &error);
      if (!success) {
        g_warning("OpenSave failed to write to '%s': %s",
                  filename, error ? error->message : "unknown error");
      }
    }
  }
  g_object_unref(native);
  return success;
}

bool Document::Exist(const std::string& file_name) {
  std::string full_path;
  if (!BuildDestinationPath(file_name, full_path)) {
    return false;
  }
  return g_file_test(full_path.c_str(), G_FILE_TEST_EXISTS);
}

std::string Document::GetPath() {
  return GetPicturesFolder();
}

std::string Document::ChoiceFolder(GtkWindow* window) {
  GtkFileChooserNative* native = gtk_file_chooser_native_new(
      "Select Folder",
      window,
      GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
      "_Select",
      "_Cancel");
  std::string current_dir = GetPicturesFolder();
  gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER(native), current_dir.c_str());

  gint res = gtk_native_dialog_run(GTK_NATIVE_DIALOG(native));
  std::string selected_path = current_dir;
  if (res == GTK_RESPONSE_ACCEPT) {
    g_autofree gchar* folder = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(native));
    if (folder != nullptr) {
      selected_path = folder;
      s_pictures_folder = selected_path;
      Settings::SetValue(savedFolderToken, selected_path);
    }
  }
  g_object_unref(native);
  return selected_path;
}

struct SaveTaskData {
  std::vector<uint8_t> data;
  std::string full_path;
};

void Document::SaveTaskThread(GTask* task,
                               gpointer source_object,
                               gpointer task_data,
                               GCancellable* cancellable) {
  auto* d = static_cast<SaveTaskData*>(task_data);
  bool ok = Save(d->data.data(), d->data.size(), d->full_path);
  g_task_return_boolean(task, ok);
}

static void FreeSaveTaskData(gpointer data) {
  delete static_cast<SaveTaskData*>(data);
}

void Document::SaveTaskDone(GObject* source_object,
                            GAsyncResult* res,
                            gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  gboolean ok = g_task_propagate_boolean(G_TASK(res), nullptr);
  g_autoptr(FlValue) result = fl_value_new_bool(ok);
  fl_method_call_respond_success(method_call, result, nullptr);
  g_object_unref(method_call);
}

struct SaveFromPathTaskData {
  std::string src_path;
  std::string full_path;
};

void Document::SaveFromPathTaskThread(GTask* task,
                                       gpointer source_object,
                                       gpointer task_data,
                                       GCancellable* cancellable) {
  auto* d = static_cast<SaveFromPathTaskData*>(task_data);
  bool ok = SaveFromPath(d->src_path, d->full_path);
  g_task_return_boolean(task, ok);
}

static void FreeSaveFromPathTaskData(gpointer data) {
  delete static_cast<SaveFromPathTaskData*>(data);
}

void Document::SaveFromPathTaskDone(GObject* source_object,
                                    GAsyncResult* res,
                                    gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  gboolean ok = g_task_propagate_boolean(G_TASK(res), nullptr);
  g_autoptr(FlValue) result = fl_value_new_bool(ok);
  fl_method_call_respond_success(method_call, result, nullptr);
  g_object_unref(method_call);
}

void Document::HandleMethodCall(FlMethodChannel* channel,
                                FlMethodCall* method_call,
                                gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  bool is_map = (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP);

  if (strcmp(method, "save") == 0) {
    if (is_map) {
      FlValue* data_val = fl_value_lookup_string(args, "data");
      FlValue* name_val = fl_value_lookup_string(args, "name");
      if (data_val != nullptr && name_val != nullptr &&
          fl_value_get_type(data_val) == FL_VALUE_TYPE_UINT8_LIST &&
          fl_value_get_type(name_val) == FL_VALUE_TYPE_STRING) {
        const uint8_t* bytes = fl_value_get_uint8_list(data_val);
        size_t len = fl_value_get_length(data_val);
        const gchar* name = fl_value_get_string(name_val);
        std::string full_path;
        if (BuildDestinationPath(name, full_path)) {
          std::vector<uint8_t> buffer;
          if (bytes != nullptr && len > 0) {
            buffer.assign(bytes, bytes + len);
          }
          auto* task_data = new SaveTaskData{
              std::move(buffer),
              full_path};
          GTask* task = g_task_new(nullptr, nullptr, SaveTaskDone, g_object_ref(method_call));
          g_task_set_task_data(task, task_data, FreeSaveTaskData);
          g_task_run_in_thread(task, SaveTaskThread);
          g_object_unref(task);
          return;
        }
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(false);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  } else if (strcmp(method, "saveFromPath") == 0) {
    if (is_map) {
      FlValue* src_val = fl_value_lookup_string(args, "source_path");
      FlValue* name_val = fl_value_lookup_string(args, "name");
      if (src_val != nullptr && name_val != nullptr &&
          fl_value_get_type(src_val) == FL_VALUE_TYPE_STRING &&
          fl_value_get_type(name_val) == FL_VALUE_TYPE_STRING) {
        const gchar* src = fl_value_get_string(src_val);
        const gchar* name = fl_value_get_string(name_val);
        std::string full_path;
        if (BuildDestinationPath(name, full_path)) {
          auto* task_data = new SaveFromPathTaskData{src, full_path};
          GTask* task = g_task_new(nullptr, nullptr, SaveFromPathTaskDone, g_object_ref(method_call));
          g_task_set_task_data(task, task_data, FreeSaveFromPathTaskData);
          g_task_run_in_thread(task, SaveFromPathTaskThread);
          g_object_unref(task);
          return;
        }
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(false);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(method, "openSave") == 0) {
    bool success = false;
    if (is_map) {
      FlValue* data_val = fl_value_lookup_string(args, "data");
      FlValue* name_val = fl_value_lookup_string(args, "name");
      if (data_val != nullptr && name_val != nullptr &&
          fl_value_get_type(data_val) == FL_VALUE_TYPE_UINT8_LIST &&
          fl_value_get_type(name_val) == FL_VALUE_TYPE_STRING) {
        success = OpenSave(fl_value_get_uint8_list(data_val),
                           fl_value_get_length(data_val),
                           fl_value_get_string(name_val),
                           s_parent_window);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
  } else if (strcmp(method, "exist") == 0) {
    bool exists = false;
    if (is_map) {
      FlValue* name_val = fl_value_lookup_string(args, "name");
      if (name_val != nullptr && fl_value_get_type(name_val) == FL_VALUE_TYPE_STRING) {
        exists = Exist(fl_value_get_string(name_val));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(exists);
    fl_method_call_respond_success(method_call, result, nullptr);
  } else if (strcmp(method, "get_path") == 0) {
    std::string path = GetPath();
    g_autoptr(FlValue) result = fl_value_new_string(path.c_str());
    fl_method_call_respond_success(method_call, result, nullptr);
  } else if (strcmp(method, "choice_folder") == 0) {
    std::string path = ChoiceFolder(s_parent_window);
    g_autoptr(FlValue) result = fl_value_new_string(path.c_str());
    fl_method_call_respond_success(method_call, result, nullptr);
  } else if (strcmp(method, "permissionStatus") == 0 ||
             strcmp(method, "requestPermission") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(TRUE);
    fl_method_call_respond_success(method_call, result, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}
