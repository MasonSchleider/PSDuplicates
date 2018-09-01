using System;
using System.Drawing;

namespace CustomControls.Extensions {
    public static class SizeExtension {
        public static float GetAspectRatio(this Size size) {
            return ((float)size.Width / size.Height);
        }
    }
}
