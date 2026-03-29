# windows-clock

A minimal, transparent desktop clock for Windows that sits in the bottom-right corner of the screen.

## Features

- Transparent, borderless overlay — always on top
- Click-through (does not steal mouse focus)
- Draggable — click and drag to reposition
- System tray icon with Exit option
- No taskbar entry

## Usage

**Run the script directly:**
```powershell
powershell -ExecutionPolicy Bypass -File clock.ps1
```

**Or run the compiled executable:**
```
clock.exe
```

## Releases

Pre-built releases are available on the [Releases page](../../releases). Each release includes:

- **`clock-setup.exe`** — installer, recommended for most users
- **`clock.zip`** — portable, just extract and run

The installer copies files to `AppData\Local\WindowsClock\` and optionally adds a "Start on login" entry during setup.

> If using the zip, `clock.ico` must be in the same folder as `clock.exe`.

### Windows SmartScreen warning

When downloading and running the exe, Windows may show an "Unknown publisher" warning. This is expected — the exe is not code-signed. To bypass it:

1. Right-click the downloaded file → **Properties** → check **Unblock** → OK
2. Or when SmartScreen appears, click **More info → Run anyway**

## Building

### Via GitHub Actions (recommended)

Push a version tag to trigger an automated build and release:

```bash
git tag v1.0
git push origin v1.0
```

GitHub Actions will compile `clock.ps1` into `clock.exe`, build the installer with Inno Setup, and publish a release with both `clock-setup.exe` and `clock.zip` attached.

### Locally

Requires [PS2EXE](https://github.com/MScholtes/PS2EXE):

```powershell
Install-Module ps2exe -Scope CurrentUser
```

With icon:
```powershell
ps2exe -inputFile clock.ps1 -outputFile clock.exe -iconFile clock.ico -noconsole -noOutput
```

Without icon:
```powershell
ps2exe -inputFile clock.ps1 -outputFile clock.exe -noconsole -noOutput
```
