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
            GtkLayerShell.set_layer(this, Layer.OVERLAY);
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

            var app_list = new ListBox();
            app_list.set_halign(Align.FILL);
            app_list.set_valign(Align.FILL);
            app_list.set_hexpand(true);
            app_list.set_vexpand(true);

            var search_box = new SearchEntry();
            search_box.insert_text.connect(() => {
                app_list.invalidate_filter();
                app_list.invalidate_sort();
            });
            search_box.delete_text.connect(() => {
                app_list.invalidate_filter();
                app_list.invalidate_sort();
            });
            search_box.activate.connect(() => {
                app_list.invalidate_filter();
                app_list.invalidate_sort();
            });

            update(app_list);
            app_list.set_filter_func((a) => {
                if(search_box.get_text() == null || search_box.get_text() == "") {
                    return true;
                }

                var button = (Button)a.get_child();
                var grid = (Grid)button.get_child();
                var label = (Label)grid.get_child_at(1, 0);

                var haystack = label.get_text();
                var needle = search_box.get_text();

                var query = new Fuzzier(needle);
                
                var match_score = query.match(haystack, 0, RegexCompileFlags.CASELESS);

                apps.search<string>(haystack, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score = match_score;

                return match_score > 0;
            });
            app_list.set_sort_func((a, b) => {
                var button = (Button)a.get_child();
                var grid = (Grid)button.get_child();
                var label = (Label)grid.get_child_at(1, 0);

                var haystack_a = label.get_text();
                
                button = (Button)b.get_child();
                grid = (Grid)button.get_child();
                label = (Label)grid.get_child_at(1, 0);

                var haystack_b = label.get_text();

                if(search_box.get_text() == null || search_box.get_text() == "") {
                    return strcmp(haystack_a, haystack_b);
                }

                var score_a = apps.search<string>(haystack_a, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score;
                var score_b = apps.search<string>(haystack_b, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score;

                return score_a > score_b ? 1 : (score_a == score_b) ? 0 : -1;
            });

            var scroll_container = new ScrolledWindow(null, null);
            scroll_container.add(app_list);

            main_container.pack_start(search_box, true, true, 0);
            main_container.pack_start(scroll_container, true, true, 0);
            add(main_container);
        }

        private void update(ListBox list) {
            foreach(var child in list.get_children())
                list.remove(child);

            unowned List<DesktopApplication> current = apps;

            foreach(var app in current) {
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

                list.prepend(button);
            }

            list.show_all();
        }
    }
}