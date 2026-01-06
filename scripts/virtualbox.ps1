# DESCRIPTION: This script automates the installation of Oracle VM VirtualBox, HashiCorp Vagrant, and Syncthing on Windows using Winget.
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
    if (Get-Command VirtualBox.exe -ErrorAction SilentlyContinue) { return $true }
    winget list --id Oracle.VirtualBox -e 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Test-VagrantInstalled {
    <#
    .SYNOPSIS
    Checks if Vagrant is installed by looking for vagrant.exe or checking WinGet.
    #>
    if (Get-Command vagrant.exe -ErrorAction SilentlyContinue) { return $true }
    winget list --id Hashicorp.Vagrant -e 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Test-SyncthingInstalled {
    <#
    .SYNOPSIS
    Checks if Syncthing is installed by looking for syncthing.exe or checking WinGet.
    #>
    if (Get-Command syncthing.exe -ErrorAction SilentlyContinue) { return $true }
    winget list --id Syncthing.Syncthing -e 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
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
    if (Test-VirtualBoxInstalled) {
        Write-Host -ForegroundColor Green "VirtualBox is already installed."
        return
    }

    Write-Host "Installing Oracle VM VirtualBox using WinGet. This may take a few minutes..."
    # Note: VirtualBox installation often requires a reboot for network drivers.
    winget install -e --id Oracle.VirtualBox --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "VirtualBox installation via WinGet failed. Please try installing it manually."
        exit 1
    }
    Write-Host "VirtualBox installed successfully."
}

function Install-Vagrant {
    <#
    .SYNOPSIS
    Installs HashiCorp Vagrant using WinGet.
    #>
    if (Test-VagrantInstalled) {
        Write-Host -ForegroundColor Green "Vagrant is already installed."
        return
    }

    Write-Host "Installing HashiCorp Vagrant using WinGet..."
    winget install -e --id Hashicorp.Vagrant --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Vagrant installation via WinGet failed. Please try installing it manually."
        exit 1
    }
    Write-Host "Vagrant installed successfully."
}

function Install-Syncthing {
    <#
    .SYNOPSIS
    Installs Syncthing using WinGet.
    #>
    if (Test-SyncthingInstalled) {
        Write-Host -ForegroundColor Green "Syncthing is already installed."
        return
    }

    Write-Host "Installing Syncthing using WinGet..."
    winget install -e --id Syncthing.Syncthing --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Syncthing installation via WinGet failed. Please try installing it manually."
        exit 1
    }
    Write-Host "Syncthing installed successfully."
}

Write-Host "Starting Installation Process..."
Write-Host "Target: VirtualBox, Vagrant, Syncthing"

# 1. Install WinGet package manager if not present.
Install-WinGet

# 2. Install Applications
Install-VirtualBox
Install-Vagrant
Install-Syncthing

# 3. Post-install instructions.
Write-Host ""
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host -ForegroundColor Green "Installation script finished."
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. A system restart is highly recommended to complete the installation of VirtualBox network drivers."
Write-Host "2. Verify installations by opening a new terminal and running:"
Write-Host "   - vagrant --version"
Write-Host "   - syncthing --version"
Write-Host "3. Start Syncthing from the Start Menu to set up the web GUI."
Write-Host ""