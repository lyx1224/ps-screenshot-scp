# PS-ScreenshotScp

Quickly upload Windows screenshots (or any file) to a remote server via SCP.

## How it works

1. Press **Win+Shift+S** to capture a screenshot (goes to clipboard).
2. Run `ss` in PowerShell — the image is saved as a PNG and uploaded via SCP.
3. If the clipboard has no image, a file picker dialog opens as fallback.

## Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- OpenSSH client (`scp` command available)
- SSH key-based auth to the remote server (passwordless)
- `.NET` assemblies: `System.Windows.Forms`, `System.Drawing` (included with Windows)

## Quick Start

### 1. Edit the target server

Open `PS-ScreenshotScp.psm1` and change these two lines:

```powershell
$script:ECS_HOST = 'root@YOUR_ECS_IP'
$script:ECS_DIR  = '/root/workspace/sshimages/'
```

### 2. Create the remote directory

```bash
ssh root@YOUR_ECS_IP "mkdir -p /root/workspace/sshimages"
```

### 3. Load the module

**Option A — one-time load:**

```powershell
Import-Module ./PS-ScreenshotScp.psm1
```

**Option B — add to PowerShell profile (persistent):**

```powershell
# Copy module to a permanent location
$moduleDir = "$HOME\Documents\PowerShell\Modules\PS-ScreenshotScp"
New-Item -ItemType Directory -Force -Path $moduleDir
Copy-Item PS-ScreenshotScp.psm1 $moduleDir\

# Add to profile
Add-Content $PROFILE 'Import-Module PS-ScreenshotScp'
Add-Content $PROFILE 'Set-Alias ss Send-Screenshot'
Add-Content $PROFILE 'Set-Alias sf Send-File'
```

Then restart PowerShell.

## Usage

| Command | Description |
|---|---|
| `ss` | Grab screenshot from clipboard → upload to server |
| `ss C:\path\to\file.png` | Upload a specific file |
| `sf C:\path\to\file` | Upload any file to the server |

Uploaded files are named `screenshot_YYYYMMDD_HHMMSS.png` on the remote server.

## Project Structure

```
ps-screenshot-scp/
├── PS-ScreenshotScp.psm1   # PowerShell module (core functions)
── README.md
```

## License

MIT
