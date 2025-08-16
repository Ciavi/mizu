using GLib;

namespace Mizu {
    public class DesktopApplication {
        public string name;
        public Icon icon;
        public string command;
        public string description;
        public int score;

        public DesktopApplication(string? name, string? description, Icon? icon, string? command) {
            this.name = name;
            this.description = description;
            this.icon = icon;
            this.command = command;
        }

        public void run() {
            var c_command = "exec %s & disown".printf(command)
                .replace("%f", "").replace("%F", "")
                .replace("%u", "").replace("%U", "")
                .replace("%d", "").replace("%D", "")
                .replace("%n", "").replace("%N", "")
                .replace("%i", "").replace("%c", "")
                .replace("%k", "").replace("%v", "")
                .replace("%m", "").strip();

            Posix.system(c_command);
            Gtk.main_quit();
        }

        public static List<DesktopApplication> compose_list() {
            var list = new List<DesktopApplication>();
            var apps = AppInfo.get_all();

            foreach(AppInfo app in apps) {
                if(!app.should_show()) continue;

                var app_entry = new DesktopApplication(app.get_display_name(), app.get_description(), app.get_icon(), app.get_commandline());
                list.append(app_entry);
            }

            list.sort_with_data((a, b) => {
                return strcmp(a.name, b.name);
            });

            return list;
        }
    }
}
