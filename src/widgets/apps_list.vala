using Gtk;

namespace Mizu {
    public class AppsList : Box {
        public List<DesktopApplication> applications;
        public SearchEntry search_box;
        public ListBox apps_list;
        
        public AppsList(List<DesktopApplication> applications) {
            this.applications = new List<DesktopApplication>();
            this.applications = applications.copy_deep((a) => {
                return a;
            });

            set_orientation(Orientation.VERTICAL);
            set_halign(Align.FILL);
            set_valign(Align.FILL);

            build_search_box();
            build_apps_list();

            var scroll_container = new ScrolledWindow(null, null);
            scroll_container.add(apps_list);

            pack_start(search_box, false, true, 0);
            pack_start(scroll_container, true, true, 0);
        }

        private void build_search_box() {
            search_box = new SearchEntry();
            search_box.set_halign(Align.FILL);
            search_box.set_valign(Align.START);
            search_box.set_hexpand(true);
            search_box.set_vexpand(false);
            search_box.set_placeholder_text(_("Search..."));
            
            search_box.insert_text.connect(() => {
                apps_list.invalidate_filter();
                apps_list.invalidate_sort();
            });
            search_box.delete_text.connect(() => {
                apps_list.invalidate_filter();
                apps_list.invalidate_sort();
            });
            search_box.activate.connect(() => {
                apps_list.invalidate_filter();
                apps_list.invalidate_sort();
            });
        }

        private void build_apps_list() {
            apps_list = new ListBox();
            update_apps_list();
            apps_list.set_halign(Align.FILL);
            apps_list.set_valign(Align.FILL);
            apps_list.set_hexpand(true);
            apps_list.set_vexpand(true);
            apps_list.set_selection_mode(SelectionMode.SINGLE);
            apps_list.get_style_context().add_class("appsList");
            apps_list.set_filter_func((a) => {
                var needle = search_box.get_text();
                if(needle == null || needle == "") {
                    return true;
                }

                var label = (Label)((Grid)((Button)a.get_child()).get_child()).get_child_at(1, 0);
                var haystack = label.get_text();
                var query = new Fuzzier(needle);
                var match_score = query.match(haystack, 0, RegexCompileFlags.CASELESS);

                applications.search<string>(haystack, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score = match_score;

                return match_score > 0;
            });
            apps_list.set_sort_func((a, b) => {
                var label = (Label)((Grid)((Button)a.get_child()).get_child()).get_child_at(1, 0);
                var haystack_a = label.get_text();

                label = (Label)((Grid)((Button)b.get_child()).get_child()).get_child_at(1, 0);
                var haystack_b = label.get_text();

                var needle = search_box.get_text();
                if(needle == null || needle == "") {
                    return strcmp(haystack_a, haystack_b);
                }

                var score_a = applications.search<string>(haystack_a, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score;
                var score_b = applications.search<string>(haystack_b, (app, name) => {
                    return app.name == name ? 1 : 0;
                }).first().data.score;

                return score_a > score_b ? 1 : (score_a == score_b) ? 0 : -1;
            });
        }

        private void update_apps_list() {
            foreach(var child in apps_list.get_children())
                apps_list.remove(child);

            var counter = 1;
            foreach(var app in applications) {
                var button = new Button();
                var grid = new Grid();
                var icon = new Image();
                icon.set_from_gicon(app.icon, IconSize.DND);

                var label = new Label(app.name);
                var description = new Label(app.description);

                grid.attach(icon, 0, 0, 1, 1);
                grid.attach(label, 1, 0, 1, 1);

                if(app.description != null && app.description != "") grid.attach(description, 1, 1, 1, 1);

                grid.show_all();

                button.set_alignment(0, 0.5f);
                button.add(grid);
                button.clicked.connect(app.run);

                if(counter < applications.length()) {
                    button.set_margin_bottom(6);
                }

                apps_list.prepend(button);
                counter++;
            }

            apps_list.show_all();
        }
    }
}