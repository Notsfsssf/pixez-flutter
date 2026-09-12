#include "plugins_manager.h"

#include "plugins/clipboard_plugin.h"
#include "plugins/document_plugin.h"
#include "plugins/paths_plugin.h"
#include "plugins/single_instance_plugin.h"
#include "plugins/weiss_plugin.h"

void RegisterPixEzPlugins(FlView* view, GtkWindow* window) {
  FlPluginRegistry* registry = FL_PLUGIN_REGISTRY(view);

  g_autoptr(FlPluginRegistrar) clipboard_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ClipboardPlugin");
  Clipboard::Initialize(clipboard_registrar);

  g_autoptr(FlPluginRegistrar) document_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DocumentPlugin");
  Document::Initialize(document_registrar, window);

  g_autoptr(FlPluginRegistrar) paths_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PathsPlugin");
  Paths::Initialize(paths_registrar);

  g_autoptr(FlPluginRegistrar) single_instance_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SingleInstancePlugin");
  SingleInstance::Initialize(single_instance_registrar);

  g_autoptr(FlPluginRegistrar) weiss_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WeissPlugin");
  Weiss::Initialize(weiss_registrar);
}
