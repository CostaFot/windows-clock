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

## Building

Requires [PS2EXE](https://github.com/MScholtes/PS2EXE):

```powershell
Install-Module ps2exe -Scope CurrentUser
```

### With a custom icon (recommended)

1. Convert your PNG to ICO using the included script:
   ```powershell
   .\ConvertTo-Ico.ps1 -PngPath "icon.png" -IcoPath "clock.ico"
   ```

2. Build with the icon:
   ```powershell
   ps2exe -inputFile clock.ps1 -outputFile clock.exe -iconFile clock.ico -noconsole -noOutput
   ```

   This sets both the `.exe` file icon (visible in Explorer) and the system tray icon at runtime.

   > `clock.ico` must be in the same folder as `clock.exe` when running.

### Without a custom icon

```powershell
ps2exe -inputFile clock.ps1 -outputFile clock.exe -noconsole -noOutput
```
