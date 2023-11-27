using Gdk;
using Gtk;

namespace Mizu {
    public class PowerMenu : Box {
        public Avatar user_button;
        public Label user_label;
        public Button terminate_button;
        public Button reboot_button;
        public Button shutdown_button;

        private Json.Object settings;

        public PowerMenu() {
            set_orientation(Orientation.HORIZONTAL);
            get_style_context().add_class("powerMenu");

            load_settings();

            user_label = new Label(Environment.get_user_name());
            user_label.get_style_context().add_class("username");

            build_power_buttons();
            build_user_button();

            pack_start(user_button, false, false, 0);
            pack_start(user_label, false, true, 12);
            pack_end(shutdown_button, false, false, 0);
            pack_end(reboot_button, false, false, 0);
            pack_end(terminate_button, false, false, 0);
        }

        private void load_settings() {
            settings = SETTINGS.get_object_member("widgets").get_object_member("powermenu");
        }

        private void build_power_buttons() {
            var commands = settings.get_object_member("commands");

            var shutdown_icon = new Image();
            shutdown_icon.set_from_icon_name("system-shutdown", IconSize.LARGE_TOOLBAR);

            shutdown_button = new Button();
            shutdown_button.set_hexpand(false);
            shutdown_button.set_vexpand(false);
            shutdown_button.set_valign(Align.CENTER);
            shutdown_button.get_style_context().add_class("systemShutdown");
            shutdown_button.set_image(shutdown_icon);
            shutdown_button.clicked.connect(() => Posix.system(commands.get_string_member_with_default("shutdown", "systemctl poweroff")));

            var reboot_icon = new Image();
            reboot_icon.set_from_icon_name("system-reboot", IconSize.LARGE_TOOLBAR);

            reboot_button = new Button();
            reboot_button.set_hexpand(false);
            reboot_button.set_vexpand(false);
            reboot_button.set_valign(Align.CENTER);
            reboot_button.get_style_context().add_class("systemReboot");
            reboot_button.set_image(reboot_icon);
            reboot_button.clicked.connect(() => Posix.system(commands.get_string_member_with_default("reboot", "systemctl reboot")));
            
            var terminate_icon = new Image();
            terminate_icon.set_from_icon_name("system-log-out", IconSize.LARGE_TOOLBAR);

            terminate_button = new Button();
            terminate_button.set_hexpand(false);
            terminate_button.set_vexpand(false);
            terminate_button.set_valign(Align.CENTER);
            terminate_button.get_style_context().add_class("systemLogOut");
            terminate_button.set_image(terminate_icon);
            terminate_button.clicked.connect(() => Posix.system(commands.get_string_member_with_default("logout", "loginctl terminate-session %s").printf(Environment.get_variable("XDG_SESSION_ID"))));
        }

        private void build_user_button() {
            var face = Path.build_filename(Environment.get_home_dir(), ".face");
            var face_icon = Path.build_filename(Environment.get_home_dir(), ".face.icon");

            Cairo.Surface user_icon = null;
            if(File.new_for_path(face).query_exists()) {
                try {
                    var buf = new Pixbuf.from_file_at_scale(face, 48, 48, true);
                    user_icon = Gdk.cairo_surface_create_from_pixbuf(buf, 1, null);
                } catch(Error e){
                    stdout.printf("%s\n", e.message);
                }
            }
            else if(File.new_for_path(face_icon).query_exists()) {
                try {
                    var buf = new Pixbuf.from_file_at_scale(face_icon, 48, 48, true);
                    user_icon = Gdk.cairo_surface_create_from_pixbuf(buf, 1, null);
                } catch(Error e){
                    stdout.printf("%s\n", e.message);
                }
            }

            user_button = new Avatar();
            user_button.get_style_context().add_class("user");
            user_button.surface = user_icon;
        }
    }
}