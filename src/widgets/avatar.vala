/*
 * Base class by corebird: https://github.com/baedert/corebird
**/

namespace Mizu {
    public class Avatar : Gtk.Widget {
        private const int SMALL = 0;
        private const int LARGE = 1;
        private bool _round = true;
        public bool make_round {
            get {
                return _round;
            }
            set {
                if (value == _round)
                    return;
    
                if (value) {
                    get_style_context().add_class("avatarRound");
                } else {
                    get_style_context().remove_class("avatarRound");
                }
    
                _round = value;
                queue_draw();
            }
        }
        public int size { get; set; default = 48; }
    
        private Cairo.ImageSurface _surface;
        public Cairo.Surface surface {
            get {
                return _surface;
            }
            set {
                if(_surface == value) return;
                _surface = (Cairo.ImageSurface)value;
    
                queue_draw();
            }
        }
        private double alpha = 1.0f;
    
        construct {
            set_has_window(false);
            this.get_style_context().add_class("avatar");
            this.get_style_context().add_class("avatarRound"); // default is TRUE
        }
    
        ~Avatar () {
    
        }
    
        public override bool draw(Cairo.Context ctx) {
            int width = size;
            int height = size;
    
            if (_surface == null) {
                return Gdk.EVENT_PROPAGATE;
            }
    
            double surface_scale;
            _surface.get_device_scale (out surface_scale, out surface_scale);
    
            if (width != height) {
                warning("Avatar with mapped with width %d and height %d", width, height);
            }
    
            var surface = new Cairo.Surface.similar(ctx.get_target(),
                                                    Cairo.Content.COLOR_ALPHA,
                                                    width, height);
            var ct = new Cairo.Context(surface);
    
            double scale = (double)get_allocated_width()
                /(double)(this._surface.get_width()/surface_scale);
    
            ct.rectangle(0, 0, width, height);
            ct.scale(scale, scale);
            ct.set_source_surface(this._surface, 0, 0);
            ct.fill();
    
            if (_round) {
                ct.scale(1.0 / scale, 1.0 / scale);
                ct.set_operator(Cairo.Operator.DEST_IN);
                ct.arc((width / 2.0), (height / 2.0),
                    (width / 2.0) - 0.5, // Radius
                    0,               // Angle from
                    2 * Math.PI);    // Angle to
                ct.fill();
    
                get_style_context().render_frame(ctx, 0, 0, width, height);
            }
    
            ctx.set_source_surface(surface, 0, 0);
            ctx.paint_with_alpha(alpha);
    
            return Gdk.EVENT_PROPAGATE;
        }
    
        public override void size_allocate (Gtk.Allocation alloc) {
            base.size_allocate (alloc);
        }
    
        public override void get_preferred_width (out int min, out int nat) {
            min = size;
            nat = size;
        }
    
        public override void get_preferred_height (out int min, out int nat) {
            min = size;
            nat = size;
        }
    }
}