Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hwnd, int nIndex, int dwNewLong);
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hwnd, int nIndex);
}
"@

$window = New-Object System.Windows.Window
$window.Title = "Clock"
$window.Width = 80
$window.Height = 35
$window.WindowStyle = "None"
$window.AllowsTransparency = $true
$window.Background = "Transparent"
$window.Topmost = $true
$window.ShowInTaskbar = $false

$windowHelper = New-Object System.Windows.Interop.WindowInteropHelper($window)
$windowHelper.EnsureHandle()

$hwnd = $windowHelper.Handle
$exStyle = [WinAPI]::GetWindowLong($hwnd, -20)
[WinAPI]::SetWindowLong($hwnd, -20, $exStyle -bor 0x80) | Out-Null

$screenWidth = [System.Windows.SystemParameters]::PrimaryScreenWidth
$screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
$window.Left = $screenWidth - $window.Width
$window.Top = $screenHeight - $window.Height

$label = New-Object System.Windows.Controls.Label
$label.FontSize = 16
$label.Foreground = "White"
$label.Padding = "0,0,0,0"
$label.VerticalContentAlignment = "Bottom"
$label.HorizontalContentAlignment = "Right"
$label.Content = (Get-Date -Format "HH:mm")

$window.Content = $label

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(60)
$timer.Add_Tick({ $label.Content = (Get-Date -Format "HH:mm") })
$timer.Start()

$window.Add_MouseLeftButtonDown({ $window.DragMove() })

$trayIcon = New-Object System.Windows.Forms.NotifyIcon
$trayIcon.Icon = [System.Drawing.SystemIcons]::Time
$trayIcon.Visible = $true
$trayIcon.Text = "Clock"

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$exitItem = $menu.Items.Add("Exit")
$exitItem.Add_Click({
    $trayIcon.Visible = $false
    $window.Close()
})
$trayIcon.ContextMenuStrip = $menu

$window.ShowDialog()