using GLib;

namespace Mizu {
    class DesktopApplication {
        public string name;
        public Icon icon;
        public string command;
        
        public DesktopApplication(string? name, Icon? icon, string? command) {
            this.name = name;
            this.icon = icon;
            this.command = command;
        }

        public void run() {
            Posix.system("exec %s & disown".printf(command));
            Gtk.main_quit();
        }

        public static List<DesktopApplication> compose_list() {
            List<DesktopApplication> list = new List<DesktopApplication>();
            List<AppInfo> apps = AppInfo.get_all();
            
            foreach(AppInfo app in apps) {
                if(!app.should_show()) continue;

                var app_entry = new DesktopApplication(app.get_display_name(), app.get_icon(), app.get_commandline());
                list.append(app_entry);
            }

            list.sort_with_data((a, b) => {
                return strcmp(a.name, b.name);
            });

            return list;
        }
    }
}