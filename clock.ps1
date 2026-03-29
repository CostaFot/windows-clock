Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, "WindowsClockSingleInstance", [ref]$createdNew)
if (-not $createdNew) {
    exit
}

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } `
    elseif ($MyInvocation.MyCommand.Path) { Split-Path $MyInvocation.MyCommand.Path } `
    else { Split-Path ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }

$configPath = "$scriptDir\clock.json"

function Load-Position {
    if (Test-Path $configPath) {
        $cfg = Get-Content $configPath | ConvertFrom-Json
        return $cfg
    }
    return $null
}

function Save-Position($left, $top) {
    @{ Left = $left; Top = $top } | ConvertTo-Json | Set-Content $configPath
}

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

$pos = Load-Position
if ($pos) {
    $window.Left = $pos.Left
    $window.Top  = $pos.Top
} else {
    $screenWidth  = [System.Windows.SystemParameters]::PrimaryScreenWidth
    $screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
    $window.Left  = $screenWidth - $window.Width
    $window.Top   = $screenHeight - $window.Height
}

$label = New-Object System.Windows.Controls.Label
$label.FontSize = 16
$label.Foreground = "White"
$label.Padding = "6,2,6,2"
$label.VerticalContentAlignment = "Center"
$label.HorizontalContentAlignment = "Center"
$label.Content = (Get-Date -Format "HH:mm")

$border = New-Object System.Windows.Controls.Border
$border.Background = [System.Windows.Media.SolidColorBrush]([System.Windows.Media.Color]::FromArgb(153, 0, 0, 0))
$border.CornerRadius = "6"
$border.Child = $label

$window.Content = $border

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(60)
$timer.Add_Tick({ $label.Content = (Get-Date -Format "HH:mm") })
$timer.Start()

$window.Add_MouseLeftButtonDown({ $window.DragMove() })
$window.Add_LocationChanged({ Save-Position $window.Left $window.Top })

$trayIcon = New-Object System.Windows.Forms.NotifyIcon
$trayIcon.Icon = New-Object System.Drawing.Icon("$scriptDir\clock.ico")
$trayIcon.Visible = $true
$trayIcon.Text = "Clock"

$trayIcon.Add_DoubleClick({
    if ($window.IsVisible) { $window.Hide() } else { $window.Show() }
})

$regKey  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "WindowsClock"
$exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

function Get-StartupEnabled {
    return (Get-ItemProperty -Path $regKey -Name $regName -ErrorAction SilentlyContinue) -ne $null
}

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$startupItem = $menu.Items.Add("Start on login")
$startupItem.Checked = Get-StartupEnabled
$startupItem.Add_Click({
    if ($startupItem.Checked) {
        Remove-ItemProperty -Path $regKey -Name $regName -ErrorAction SilentlyContinue
        $startupItem.Checked = $false
    } else {
        Set-ItemProperty -Path $regKey -Name $regName -Value $exePath
        $startupItem.Checked = $true
    }
})

$exitItem = $menu.Items.Add("Exit")
$exitItem.Add_Click({
    $trayIcon.Visible = $false
    $window.Close()
})
$trayIcon.ContextMenuStrip = $menu

$window.ShowDialog()