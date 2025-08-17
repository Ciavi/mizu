using Gtk;

public static Json.Object SETTINGS;
public static string BUS_NAME;

namespace Mizu {
    public class Client : Object {
        Launcher launcher;

        public Client(string[] args, uint owner_id) {
            Gtk.init(ref args);

            set_settings();
            set_style();
            launcher = new Launcher(owner_id);
            launcher.show_all();

            Gtk.main();
        }

        private void set_settings() {
            try {
                var parser = new Json.Parser();
                parser.load_from_file(Path.build_filename(Environment.get_home_dir(), ".config/mizu", "config.json"));

                var root = parser.get_root().get_object();
                SETTINGS = root;
            } catch(Error e) {
                stderr.printf("%s\n", e.message);
                Gtk.main_quit();
            }
        }

        private void set_style() {
            var css_provider = new CssProvider();

            try {
                css_provider.load_from_path(Path.build_filename(Environment.get_home_dir(), ".config/mizu", "style.css"));

                Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch(Error e) {
                stderr.printf("%s\n", e.message);
            }
        }
    }
}

int main(string[] args) {
    BUS_NAME = "it.lichtzeit.mizu";

    Intl.setlocale(LocaleCategory.ALL, "");

    var langpack_dir = Path.build_filename(Mizu.PREFIX, "share", "locale");
    Intl.bindtextdomain(Mizu.PACKAGE, langpack_dir);
    Intl.bind_textdomain_codeset(Mizu.PACKAGE, "UTF-8");
    Intl.textdomain(Mizu.PACKAGE);

    uint owner_id = Bus.own_name(
        BusType.SESSION,
        BUS_NAME,
        BusNameOwnerFlags.NONE,
        (conn) => {
            // acquired callback
            stdout.printf("Acquired bus name %s\n", BUS_NAME);
        },
        () => {},
        () => {
            // lost callback (someone else owns it)
            stderr.printf("Another instance is already running.\n");
            Posix.exit(1);
        }
    );

    new Mizu.Client(args, owner_id);
    return 0;
}
