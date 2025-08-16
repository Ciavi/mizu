using Gdk;
using GLib;
using Gtk;
using GtkLayerShell;

namespace Mizu {
    class Margin {
        public Edge edge;
        public int margin;

        public Margin(Edge edge, int margin = 0) {
            this.edge = edge;
            this.margin = margin;
        }
    }

    class Launcher : Gtk.Window {
        public List<DesktopApplication> apps;
        public Json.Object settings;

        public Launcher() {
            settings = SETTINGS.get_object_member("general");

            var l_width = settings.get_int_member_with_default("width", 480);
            var l_height = settings.get_int_member_with_default("height", 540);

            set_size_request(int.parse(l_width.to_string()), int.parse(l_height.to_string()));

            var l_anchors = settings.get_string_member_with_default("anchors", "top left").split(" ", 4);
            var l_margins = settings.get_string_member_with_default("margins", "0 0 0 0").split(" ", 4);

            List<Edge> anchors = new List<Edge>();
            List<Margin> margins = new List<Margin>();

            foreach(var l_anchor in l_anchors) {
                anchors.append(string_to_edge(l_anchor));
            }

            switch(l_margins.length) {
                case 4:
                    margins.append(new Margin(Edge.TOP, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.RIGHT, int.parse(l_margins[1])));
                    margins.append(new Margin(Edge.BOTTOM, int.parse(l_margins[2])));
                    margins.append(new Margin(Edge.LEFT, int.parse(l_margins[3])));
                    break;
                case 3:
                    margins.append(new Margin(Edge.TOP, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.RIGHT, int.parse(l_margins[1])));
                    margins.append(new Margin(Edge.BOTTOM, int.parse(l_margins[2])));
                    margins.append(new Margin(Edge.LEFT, int.parse(l_margins[1])));
                    break;
                case 2:
                    margins.append(new Margin(Edge.TOP, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.RIGHT, int.parse(l_margins[1])));
                    margins.append(new Margin(Edge.BOTTOM, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.LEFT, int.parse(l_margins[1])));
                    break;
                case 1:
                    margins.append(new Margin(Edge.TOP, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.RIGHT, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.BOTTOM, int.parse(l_margins[0])));
                    margins.append(new Margin(Edge.LEFT, int.parse(l_margins[0])));
                    break;
                case 0:
                default:
                    margins.append(new Margin(Edge.TOP));
                    margins.append(new Margin(Edge.LEFT));
                    break;
            }

            GtkLayerShell.init_for_window(this as Gtk.Window);
            GtkLayerShell.auto_exclusive_zone_enable(this);
            GtkLayerShell.set_keyboard_mode(this, KeyboardMode.ON_DEMAND);
            GtkLayerShell.set_layer(this, Layer.OVERLAY);

            foreach(var anchor in anchors) {
                GtkLayerShell.set_anchor(this, anchor, true);
            }

            foreach(var margin in margins) {
                GtkLayerShell.set_margin(this, margin.edge, margin.margin);
            }

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

        private Edge string_to_edge(string name) {
            switch(name) {
                case "top":
                    return Edge.TOP;
                case "bottom":
                    return Edge.BOTTOM;
                case "left":
                default:
                    return Edge.LEFT;
                case "Right":
                    return Edge.RIGHT;
            }
        }
    }
}
