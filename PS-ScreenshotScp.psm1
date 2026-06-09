# PS-ScreenshotScp.psm1
# Upload screenshots or files to a remote server via SCP.
# Clipboard image → save as PNG → SCP upload.
# Fallback: file picker dialog when clipboard is empty.

# --- Configuration (edit these) ---
$script:ECS_HOST = 'root@YOUR_ECS_IP'
$script:ECS_DIR  = '/root/workspace/sshimages/'

function Send-Screenshot {
    <#
    .SYNOPSIS
        Upload a screenshot from clipboard (or a specified file) to a remote server via SCP.
    .DESCRIPTION
        1. If -FilePath is given, upload that file directly.
        2. Otherwise, grab the latest image from the Windows clipboard (e.g. Win+Shift+S).
        3. If clipboard has no image, open a file picker dialog.
        4. SCP the file to the remote server with a timestamped filename.
    .EXAMPLE
        Send-Screenshot
        Send-Screenshot -FilePath C:\temp\image.png
        ss          # alias
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$FilePath
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $tmpDir  = [System.IO.Path]::GetTempPath()
    $ts      = Get-Date -Format 'yyyyMMdd_HHmmss'
    $remoteName = "screenshot_${ts}.png"

    if ($FilePath -and (Test-Path $FilePath)) {
        $localFile = $FilePath
    } else {
        $clipImg = $null
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                $clipImg = [System.Windows.Forms.Clipboard]::GetImage()
            }
        } catch { }

        if ($clipImg) {
            $localFile = Join-Path $tmpDir $remoteName
            $clipImg.Save($localFile, [System.Drawing.Imaging.ImageFormat]::Png)
            $clipImg.Dispose()
        } else {
            $dlg = New-Object System.Windows.Forms.OpenFileDialog
            $dlg.Title = 'Select a file to upload'
            $dlg.Filter = 'Image Files (*.png;*.jpg;*.jpeg;*.gif;*.bmp;*.webp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp;*.webp|All Files (*.*)|*.*'
            if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $localFile = $dlg.FileName
            } else {
                Write-Host 'Cancelled.' -ForegroundColor Yellow
                return
            }
        }
    }

    Write-Host "Uploading $localFile -> ${ECS_HOST}:${ECS_DIR}${remoteName}" -ForegroundColor Cyan
    scp $localFile "${ECS_HOST}:${ECS_DIR}${remoteName}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Done: ${ECS_DIR}${remoteName}" -ForegroundColor Green
    } else {
        Write-Host 'Upload failed. Check SSH connectivity.' -ForegroundColor Red
    }
}

function Send-File {
    <#
    .SYNOPSIS
        Upload any file to the remote server via SCP.
    .EXAMPLE
        Send-File C:\temp\doc.pdf
        sf C:\temp\doc.pdf    # alias
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Red
        return
    }

    $fileName = [System.IO.Path]::GetFileName($FilePath)
    Write-Host "Uploading $FilePath -> ${ECS_HOST}:${ECS_DIR}${fileName}" -ForegroundColor Cyan
    scp $FilePath "${ECS_HOST}:${ECS_DIR}${fileName}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Done: ${ECS_DIR}${fileName}" -ForegroundColor Green
    } else {
        Write-Host 'Upload failed. Check SSH connectivity.' -ForegroundColor Red
    }
}

Export-ModuleMember -Function Send-Screenshot, Send-File
