# DESCRIPTION: This script automates the installation of Oracle VM VirtualBox on Windows using Winget.
#
# USAGE: Execute this script with Administrator privileges.

# Ensure script is run as Administrator.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator privileges. Attempting to relaunch as Administrator..."
    Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

# Set execution policy for the current user to allow script execution.
set-executionpolicy -scope CurrentUser -executionPolicy Bypass -Force

# Suppress progress bars for a cleaner output.
$ProgressPreference = 'SilentlyContinue'

function Test-VirtualBoxInstalled {
    <#
    .SYNOPSIS
    Checks if VirtualBox is installed by looking for VirtualBox.exe or checking WinGet.
    #>
    return [bool](Get-Command VirtualBox.exe -ErrorAction SilentlyContinue) -or `
           [bool](winget list --id Oracle.VirtualBox -e -q 2>$null)
}

function Install-WinGet {
    <#
    .SYNOPSIS
    Checks if WinGet is installed and installs it if it's missing.
    #>
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "WinGet not found. Installing the 'Microsoft.WinGet.Client' PowerShell module..."
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope CurrentUser
        
        # This command bootstraps/repairs the winget installation
        Repair-WinGetPackageManager

        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Error "Failed to install WinGet. Please install it manually from the Microsoft Store and re-run this script."
            exit 1
        }
        Write-Host "WinGet installed successfully."
    } else {
        Write-Host "WinGet is already installed."
    }
}

function Install-VirtualBox {
    <#
    .SYNOPSIS
    Installs Oracle VM VirtualBox using WinGet.
    #>
    Write-Host "Installing Oracle VM VirtualBox using WinGet. This may take a few minutes..."
    # Note: VirtualBox installation often requires a reboot for network drivers.
    winget install -e --id Oracle.VirtualBox --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "VirtualBox installation via WinGet failed. Please try installing it manually."
        exit 1
    }
    Write-Host "VirtualBox installed successfully."
}

# Check if VirtualBox is already installed.
if (Test-VirtualBoxInstalled) {
    Write-Host -ForegroundColor Green "VirtualBox seems to be installed already. No action needed."
    exit
}

Write-Host "Starting VirtualBox installation process..."

# 1. Install WinGet package manager if not present.
Install-WinGet

# 2. Install VirtualBox.
Install-VirtualBox

# 3. Post-install instructions.
Write-Host ""
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host -ForegroundColor Green "VirtualBox installation script finished."
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. A system restart is highly recommended to complete the installation of VirtualBox network drivers."
Write-Host "2. Start VirtualBox from the Start Menu."
Write-Host ""
