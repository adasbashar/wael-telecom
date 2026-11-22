using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace StoreApp
{
    static class Brand
    {
#if STORE_SHAM
        public const string Title = "شام للاتصالات - Sham Telecom";
        public const string DataFolder = "ShamTelecom";
#else
        public const string Title = "Wael Telecom - وائل تيليكوم";
        public const string DataFolder = "WaelTelecom";
#endif
    }

    static class Program
    {
        [DllImport("user32.dll")] static extern bool SetProcessDPIAware();

        [STAThread]
        static void Main()
        {
            try { SetProcessDPIAware(); } catch { }
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }

    class MainForm : Form
    {
        const string Host = "app.example";
        readonly WebView2 web;
        static readonly Color Bg = Color.FromArgb(11, 19, 16);

        public MainForm()
        {
            Text = Brand.Title;
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(1200, 860);
            MinimumSize = new Size(420, 600);
            BackColor = Bg;
            try { Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath); } catch { }

            web = new WebView2 { Dock = DockStyle.Fill, DefaultBackgroundColor = Bg };
            Controls.Add(web);
            Load += async (s, e) => await InitAsync();
        }

        async Task InitAsync()
        {
            try
            {
                // Data lives in %LOCALAPPDATA%\<Store>\WebView2 – separate per store, survives app updates.
                string dataDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), Brand.DataFolder, "WebView2");
                var env = await CoreWebView2Environment.CreateAsync(null, dataDir);
                await web.EnsureCoreWebView2Async(env);
                var core = web.CoreWebView2;

                string appDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "app");
                core.SetVirtualHostNameToFolderMapping(Host, appDir, CoreWebView2HostResourceAccessKind.Allow);

                core.Settings.AreDevToolsEnabled = false;
                core.Settings.IsStatusBarEnabled = false;
                core.Settings.IsZoomControlEnabled = true;

                // allow the webcam without asking every time
                core.PermissionRequested += (s, e) =>
                {
                    if (e.PermissionKind == CoreWebView2PermissionKind.Camera)
                        e.State = CoreWebView2PermissionState.Allow;
                };

                // external links open in the normal browser
                core.NewWindowRequested += (s, e) =>
                {
                    e.Handled = true;
                    try { Process.Start(new ProcessStartInfo(e.Uri) { UseShellExecute = true }); } catch { }
                };
                core.NavigationStarting += (s, e) =>
                {
                    if (!e.Uri.StartsWith("https://" + Host + "/") && !e.Uri.StartsWith("about:") && !e.Uri.StartsWith("data:"))
                    {
                        e.Cancel = true;
                        try { Process.Start(new ProcessStartInfo(e.Uri) { UseShellExecute = true }); } catch { }
                    }
                };

                web.Source = new Uri("https://" + Host + "/index.html");
            }
            catch (WebView2RuntimeNotFoundException)
            {
                var r = MessageBox.Show(
                    "This app needs Microsoft Edge WebView2 Runtime (free, from Microsoft).\n\nOpen the download page now?",
                    Brand.Title, MessageBoxButtons.YesNo, MessageBoxIcon.Information);
                if (r == DialogResult.Yes)
                    try { Process.Start(new ProcessStartInfo("https://go.microsoft.com/fwlink/p/?LinkId=2124703") { UseShellExecute = true }); } catch { }
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Could not start the app:\n" + ex.Message, Brand.Title, MessageBoxButtons.OK, MessageBoxIcon.Error);
                Close();
            }
        }
    }
}
