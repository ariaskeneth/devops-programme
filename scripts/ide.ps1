# DESCRIPTION: This script automates the installation of VS Code, Git (Git Bash), and Windows Terminal on Windows using Winget.
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

function Install-VSCode {
    <#
    .SYNOPSIS
    Checks for and installs Microsoft Visual Studio Code.
    #>
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green "VS Code is already installed."
        return
    }

    Write-Host "Installing Microsoft Visual Studio Code..."
    winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "VS Code installed successfully."
    } else {
        Write-Error "VS Code installation failed."
    }
}

function Install-Git {
    <#
    .SYNOPSIS
    Checks for and installs Git.
    #>
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host -ForegroundColor Green "Git is already installed."
        return
    }

    Write-Host "Installing Git..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Git installed successfully."
    } else {
        Write-Error "Git installation failed."
    }
}

function Install-WindowsTerminal {
    <#
    .SYNOPSIS
    Checks for and installs Windows Terminal.
    #>
    # Windows Terminal executable is 'wt.exe', but it's a store app, so Get-Command might not always find it if the alias isn't set for the admin user context yet.
    # However, winget list is a reliable fallback.
    $isInstalled = (Get-Command wt -ErrorAction SilentlyContinue) -or (winget list --id Microsoft.WindowsTerminal -e -q 2>$null)

    if ($isInstalled) {
        Write-Host -ForegroundColor Green "Windows Terminal is already installed."
        return
    }

    Write-Host "Installing Windows Terminal..."
    winget install -e --id Microsoft.WindowsTerminal --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Windows Terminal installed successfully."
    } else {
        Write-Error "Windows Terminal installation failed."
    }
}

Write-Host "Starting IDE and Tools installation process..."

# 1. Install WinGet package manager if not present.
Install-WinGet

# 2. Install Tools
Install-WindowsTerminal
Install-Git
Install-VSCode

# 3. Post-install instructions.
Write-Host ""
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host -ForegroundColor Green "IDE installation script finished."
Write-Host -ForegroundColor Green "--------------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. Restart your terminal or computer to ensure all new PATH variables are loaded."
Write-Host "2. You can launch VS Code by typing 'code' in your terminal."
Write-Host "3. You can launch Git Bash or use 'git' commands in any terminal."
Write-Host ""
