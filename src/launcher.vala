using Gdk;
using GLib;
using Gtk;
using GtkLayerShell;

namespace Mizu {
    class Launcher : Gtk.Window {
        public List<DesktopApplication> apps;
        public Json.Object settings;
        
        public Launcher() {
            settings = SETTINGS.get_object_member("general");

            var l_width = settings.get_int_member_with_default("width", 480);
            var l_height = settings.get_int_member_with_default("height", 540);

            set_size_request(int.parse(l_width.to_string()), int.parse(l_height.to_string()));

            GtkLayerShell.init_for_window(this as Gtk.Window);
            GtkLayerShell.auto_exclusive_zone_enable(this);
            GtkLayerShell.set_keyboard_mode(this, KeyboardMode.ON_DEMAND);
            GtkLayerShell.set_layer(this, Layer.OVERLAY);
            GtkLayerShell.set_margin(this, Edge.TOP, 12);
            GtkLayerShell.set_margin(this, Edge.LEFT, 12);
            GtkLayerShell.set_anchor(this, Edge.TOP, true);
            GtkLayerShell.set_anchor(this, Edge.LEFT, true);

            register_keybinds();

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

            var power_menu = new PowerMenu();

            var apps_list = new AppsList(apps);
            apps_list.set_spacing(24);

            main_container.pack_start(power_menu, false, true, 0);
            main_container.pack_start(apps_list, true, true, 0);
            add(main_container);
        }

        private void register_keybinds() {
            add_events(EventMask.KEY_PRESS_MASK);
            key_press_event.connect((key) => {
                if(key.keyval == Gdk.Key.Escape) {
                    Gtk.main_quit();
                    return true;
                }

                return false;
            });
        }
    }
}