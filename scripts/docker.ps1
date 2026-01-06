# DESCRIPTION: This script automates the installation of Docker Desktop on Windows,
# including enabling required Windows features like WSL2 and Hyper-V, and installing Winget if needed.
#
# USAGE: Execute this script with Administrator privileges. It will guide you through the process.
# If a reboot is required after enabling Windows features, you will need to run the script again after rebooting.

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

function Test-DockerInstalled {
    <#
    .SYNOPSIS
    Checks if Docker is installed by looking for docker.exe in the PATH.
    #>
    return [bool](Get-Command docker.exe -ErrorAction SilentlyContinue)
}

function Enable-WindowsFeatures {
    <#
    .SYNOPSIS
    Checks for and enables required Windows features for Docker Desktop.
    If a reboot is required, the script will exit and instruct the user to reboot and re-run.
    #>
    $features = @(
        @{Name = "Microsoft-Hyper-V-All"; Display = "Hyper-V" },
        @{Name = "Microsoft-Windows-Subsystem-Linux"; Display = "WSL" },
        @{Name = "Containers"; Display = "Containers" },
        @{Name = "VirtualMachinePlatform"; Display = "Virtual Machine Platform" }
    )

    $rebootRequired = $false
    Write-Host "Checking required Windows features..."
    foreach ($feature in $features) {
        $status = Get-WindowsOptionalFeature -FeatureName $feature.Name -Online
        if ($status.State -ne "Enabled") {
            Write-Host "$($feature.Display) is disabled. Enabling it now."
            Enable-WindowsOptionalFeature -Online -FeatureName $feature.Name -All -NoRestart
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0) {
                Write-Host "$($feature.Display) enabled successfully."
            } elseif ($exitCode -eq 3010) { # 3010 means success but reboot required
                Write-Host "$($feature.Display) enabled. A reboot is required to complete the setup."
                $rebootRequired = $true
            } else {
                Write-Error "Failed to enable $($feature.Display). Exit code: $exitCode. Please check the logs and try again."
                exit 1
            }
        } else {
            Write-Host "$($feature.Display) is already enabled."
        }
    }

    if ($rebootRequired) {
        Write-Host ""
        Write-Host -ForegroundColor Yellow "A reboot is required to apply Windows feature changes. Your computer will restart in 5 seconds."
        Restart-Computer -Force -Delay 5
        exit # Exit ensures the script terminates after initiating reboot.
    }
}

function Update-WslKernel {
    <#
    .SYNOPSIS
    Updates the WSL kernel, trying the modern 'wsl --update' command first,
    and falling back to a manual install if needed.
    #>
    Write-Host "Updating WSL and setting WSL2 as default..."
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        wsl.exe --update
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "'wsl --update' failed. Attempting manual kernel update."
            Install-WslKernelManual
        }
        wsl.exe --set-default-version 2
    } else {
        # This should not happen if Enable-WindowsFeatures was successful and the user rebooted.
        Write-Warning "WSL command not found. Attempting manual kernel update."
        Install-WslKernelManual
    }
}

function Install-WslKernelManual {
    <#
    .SYNOPSIS
    Manually downloads and installs the WSL2 Linux kernel update.
    #>
    if ([Environment]::Is64BitOperatingSystem) {
        Write-Host "Downloading and installing WSL2 Linux kernel update..."
        $msiPath = Join-Path $env:TEMP "wsl_update_x64.msi"
        if (-not (Test-Path $msiPath)) {
            $url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
            Invoke-WebRequest -Uri $url -OutFile $msiPath
        }
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msiPath`" /quiet"
        Write-Host "WSL2 Linux kernel update package installed."
        if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
            wsl.exe --set-default-version 2
        }
    } else {
        Write-Error "This script only supports x64 systems for manual WSL2 kernel updates."
        exit 1
    }
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

function Install-Docker {
    <#
    .SYNOPSIS
    Installs Docker Desktop using WinGet.
    #>
    Write-Host "Installing Docker Desktop using WinGet. This may take a few minutes..."
    winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker Desktop installation via WinGet failed. Please try installing it manually."
        exit 1
    }
    Write-Host "Docker Desktop installed successfully."
    Write-Host -ForegroundColor Yellow "A reboot is required to finish installation. Your computer will restart in 5 seconds."
    Restart-Computer -Force -Delay 5
}

# Check if Docker is already installed.
if (Test-DockerInstalled) {
    Write-Host -ForegroundColor Green "Docker seems to be installed already. No action needed."
    exit
}

Write-Host "Starting Docker Desktop installation process..."

# 1. Enable Required Windows Features (and reboot if necessary).
Enable-WindowsFeatures

# 2. Update WSL Kernel and install winget if not present.
Update-WslKernel
Install-WinGet

# 3. Install Docker Desktop.
Install-Docker

# 5. Post-install instructions.
Write-Host ""
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host -ForegroundColor Green "Docker Desktop installation script finished."
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. A system restart is required for all changes to take effect."
Write-Host "2. Start Docker Desktop from the Start Menu. It may perform a one-time setup on its first launch."
Write-Host "3. After Docker Desktop is running, open a new PowerShell terminal to use 'docker' commands."
Write-Host ""
