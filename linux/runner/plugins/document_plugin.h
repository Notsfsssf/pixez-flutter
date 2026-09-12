#ifndef PLUGINS_DOCUMENT_PLUGIN_H_
#define PLUGINS_DOCUMENT_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <string>

class Document {
 private:
  static std::string name;
  static std::string savedFolderToken;
  static std::string s_pictures_folder;
  static GtkWindow* s_parent_window;

  static std::string GetPicturesFolder();
  static bool BuildDestinationPath(const std::string& file_name, std::string& out_path);
  static bool Save(const uint8_t* data, size_t length, const std::string& full_path);
  static bool SaveFromPath(const std::string& source_path, const std::string& full_path);
  static bool OpenSave(const uint8_t* data, size_t length, const std::string& file_name, GtkWindow* window);
  static bool Exist(const std::string& file_name);
  static std::string GetPath();
  static std::string ChoiceFolder(GtkWindow* window);

  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

  static void SaveTaskThread(GTask* task,
                             gpointer source_object,
                             gpointer task_data,
                             GCancellable* cancellable);
  static void SaveTaskDone(GObject* source_object,
                           GAsyncResult* res,
                           gpointer user_data);
  static void SaveFromPathTaskThread(GTask* task,
                                     gpointer source_object,
                                     gpointer task_data,
                                     GCancellable* cancellable);
  static void SaveFromPathTaskDone(GObject* source_object,
                                   GAsyncResult* res,
                                   gpointer user_data);

 public:
  static void Initialize(FlPluginRegistrar* registrar, GtkWindow* window);
};

#endif  // PLUGINS_DOCUMENT_PLUGIN_H_
