using CustomControls.Extensions;
using System;
using System.Drawing;
using System.Reflection;
using System.Windows.Forms;

namespace CustomControls {
    [System.ComponentModel.DesignerCategory("Code")]
    public class GrowLabel : Control {
        private const float AspectRatioTolerance = 0.1f;

        public GrowLabel() : this(1.618f) { }

        public GrowLabel(float preferredAspectRatio) {
            AutoSize = false;
            PreferredAspectRatio = preferredAspectRatio;

            ContentControl = new Label();
            ContentControl.Dock = DockStyle.Fill;
            ContentControl.TextChanged += OnContentControlTextChanged;
            Controls.Add(ContentControl);
        }

        #region Events

        protected override void OnLayout(LayoutEventArgs levent) {
            base.OnLayout(levent);

            Form parentForm = FindForm();
            if (parentForm == null) return;

            Size marginSize = parentForm.Size - DisplayRectangle.Size;

            if (!parentForm.MaximumSize.IsEmpty) {
                MaximumSize = parentForm.MaximumSize - marginSize;
            } else {
                MaximumSize = Screen.PrimaryScreen.WorkingArea.Size - marginSize;
            }
            if (!parentForm.MinimumSize.IsEmpty) {
                MinimumSize = parentForm.MinimumSize - marginSize;
            } else {
                MinimumSize = DefaultSize;
            }
        }

        protected void OnContentControlTextChanged(object sender, EventArgs e) {
            Size proposedSize = new Size(MaximumSize.Width, MinimumSize.Height);
            Size preferredSize = ContentControl.GetPreferredSize(proposedSize);

            while (Math.Abs(preferredSize.GetAspectRatio() - PreferredAspectRatio) > AspectRatioTolerance) {
                float factor = (float)Math.Sqrt(PreferredAspectRatio / preferredSize.GetAspectRatio());
                int proposedWidth = (int)Math.Max(preferredSize.Width * factor, MinimumSize.Width);
                proposedSize = new Size(proposedWidth, int.MaxValue);
                preferredSize = ContentControl.GetPreferredSize(proposedSize);

                if ((preferredSize.Width <= MinimumSize.Width && preferredSize.GetAspectRatio() >= PreferredAspectRatio) ||
                        preferredSize.Height <= MinimumSize.Height) {
                    break;
                }
            }
            Size = preferredSize;
        }

        #endregion

        #region Properties

        public float AspectRatio {
            get {
                return Size.GetAspectRatio();
            }
        }

        public float PreferredAspectRatio { get; set; }

        private Label ContentControl { get; set; }

        protected override Size DefaultMaximumSize {
            get {
                PropertyInfo propertyInfo = typeof(Label).GetProperty("DefaultMaximumSize", BindingFlags.Instance | BindingFlags.NonPublic);
                return (Size)propertyInfo.GetValue(new Label());
            }
        }

        protected override Size DefaultMinimumSize {
            get {
                PropertyInfo propertyInfo = typeof(Label).GetProperty("DefaultMinimumSize", BindingFlags.Instance | BindingFlags.NonPublic);
                return (Size)propertyInfo.GetValue(new Label());
            }
        }

        protected override Size DefaultSize {
            get {
                PropertyInfo propertyInfo = typeof(Label).GetProperty("DefaultSize", BindingFlags.Instance | BindingFlags.NonPublic);
                return (Size)propertyInfo.GetValue(new Label());
            }
        }

        public new Size MaximumSize {
            get {
                return base.MaximumSize;
            }
            private set {
                base.MaximumSize = value;
            }
        }

        public new Size MinimumSize {
            get {
                return base.MinimumSize;
            }
            private set {
                base.MinimumSize = value;
            }
        }

        public new Size Size {
            get {
                return base.Size;
            }
            private set {
                base.Size = value;
            }
        }

        public override string Text {
            get {
                return ContentControl.Text;
            }
            set {
                ContentControl.Text = value;
            }
        }

        #endregion
    }
}
