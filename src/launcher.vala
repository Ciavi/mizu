using GLib;
using Gtk;
using GtkLayerShell;

namespace Mizu {
    class Launcher : Gtk.Window {
        public List<DesktopApplication> apps;

        public Launcher() {
            set_size_request(480, 540);

            GtkLayerShell.init_for_window(this as Gtk.Window);
            GtkLayerShell.auto_exclusive_zone_enable(this);
            GtkLayerShell.set_margin(this, Edge.TOP, 12);
            GtkLayerShell.set_margin(this, Edge.LEFT, 12);
            GtkLayerShell.set_anchor(this, Edge.TOP, true);
            GtkLayerShell.set_anchor(this, Edge.LEFT, true);

            destroy.connect(Gtk.main_quit);

            build();
        }

        private void build() {
            apps = DesktopApplication.compose_list();

            var main_container = new Box(Orientation.VERTICAL, 24);
            main_container.set_margin_top(24);
            main_container.set_margin_bottom(24);
            main_container.set_margin_start(24);
            main_container.set_margin_end(24);
            main_container.set_halign(Align.FILL);
            main_container.set_valign(Align.FILL);
            main_container.set_hexpand(true);
            main_container.set_vexpand(true);

            var app_list = new Box(Orientation.VERTICAL, 6);
            app_list.set_halign(Align.FILL);
            app_list.set_valign(Align.FILL);
            app_list.set_hexpand(true);
            app_list.set_vexpand(true);

            foreach(DesktopApplication app in apps) {
                var button = new Button();
                
                var grid = new Grid();

                var icon = new Image();
                icon.set_from_gicon(app.icon, IconSize.DND);

                var label = new Label(app.name);

                grid.attach(icon, 0, 0, 1, 1);
                grid.attach(label, 1, 0, 1, 1);
                grid.show_all();

                button.set_alignment(0, 0.5f);
                button.add(grid);
                button.clicked.connect(app.run);

                app_list.pack_start(button, false, true, 0);
            }

            var scroll_container = new ScrolledWindow(null, null);
            scroll_container.add(app_list);

            main_container.pack_start(scroll_container, true, true, 0);
            add(main_container);
        }
    }
}