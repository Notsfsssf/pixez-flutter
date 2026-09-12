#ifndef PIXEZ_PLUGIN_REGISTRANT_
#define PIXEZ_PLUGIN_REGISTRANT_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

// Registers Flutter plugins for PixEz.
void RegisterPixEzPlugins(FlView* view, GtkWindow* window);

#endif  // PIXEZ_PLUGIN_REGISTRANT_
