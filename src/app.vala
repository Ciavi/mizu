using Gtk;

namespace Mizu {
    public class Client : Object {
        Launcher launcher;

        public Client(string[] args) {
            Gtk.init(ref args);
            
            launcher = new Launcher();
            //set_style(launcher);
            launcher.show_all();

            Gtk.main();
        }

        private void set_style(Window window) {
            var css_provider = new CssProvider();

            try {
                css_provider.load_from_path(Path.build_filename(PREFIX, DATADIR, ""));

                var style_context = window.get_style_context();
                style_context.add_provider(css_provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch(Error e) {
                stderr.printf("%s\n", e.message);
            }
        }
    }
}

int main(string[] args) {
    new Mizu.Client(args);
    return 0;
}