set-executionpolicy -scope CurrentUser -executionPolicy Bypass -Force

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

$ProgressPreference = 'SilentlyContinue'

 Function GenerateFolder($path) {
    $global:foldPath = $null
    foreach($foldername in $path.split("\")) {
        $global:foldPath += ($foldername+"\")
        if (!(Test-Path $global:foldPath)){
            New-Item -ItemType Directory -Path $global:foldPath
            # Write-Host "$global:foldPath Folder Created Successfully"
        }
    }
}

function getStatus
{
    try {
        # First we create the request.
    $HTTP_Request = [System.Net.WebRequest]::Create('http://localhost')

    # We then get a response from the site.
    $HTTP_Response = $HTTP_Request.GetResponse()

    # We then get the HTTP code as an integer.
    return  [int]$HTTP_Response.StatusCode
    } catch [System.Net.WebException] {

    }
}

GenerateFolder "~/AppData/Roaming/Docker/"

Write-Host "Checking if Hyper-V is enabled."
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online

# Check if Hyper-V is enabled
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
    
    $wsl = Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online

    if($wsl.State -eq "Enabled") {
       
        Write-Host "WSL is enabled."

        if ([Environment]::Is64BitOperatingSystem)
        {
            Write-Host "System is x64. Need to update Linux kernel..."
            if (-not (Test-Path wsl_update_x64.msi))
            {
                Write-Host "Downloading Linux kernel update package..."
                Invoke-WebRequest -OutFile wsl_update_x64.msi https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
            }
            Write-Host "Installing Linux kernel update package..."
            Start-Process msiexec.exe -Wait -ArgumentList '/I wsl_update_x64.msi /quiet'
            Write-Host "Linux kernel update package installed."
        }

        Write-Host "WSL is enabled. Setting it to WSL2"
        wsl --set-default-version 2

        if (-not (Test-Path DockerInstaller.exe))
        {
            $progressPreference = 'silentlyContinue'
            Write-Host "Installing WinGet PowerShell module from PSGallery..."
            Install-PackageProvider -Name NuGet -Force | Out-Null
            Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
            Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
            Repair-WinGetPackageManager

            Write-Host "Installing Docker."
            winget install -e --id Docker.DockerDesktop
            cd "C:\Program Files\Docker\Docker\"
            Write-Host "Winget Installing Docker..."
            $ProgressPreference = 'SilentlyContinue'
            $env:Path += ";C:\Program Files\Docker\Docker\Resources\bin"
            $env:Path += ";C:\Program Files\Docker\Docker\Resources"
            Write-Host "Docker Installed successfully"
            Write-Host "You must reboot the sytem to continue. After reboot re-run the script."
            Restart-Computer -Confirm 
        }
        Write-Host "Starting docker..."
        $ErrorActionPreference = 'SilentlyContinue';
        do { $var1 = docker ps 2>$null } while (-Not $var1)
        $ErrorActionPreference = 'Stop';
        $env:Path += ";C:\Program Files\Docker\Docker\Resources\bin"
        $env:Path += ";C:\Program Files\Docker\Docker\Resources"
        Write-Host "Docker Started successfully"
    
        
    } 
    else {
        Write-Host "WSL is disabled."
        Write-Host "Enabling WSL2 feature now"
    
        & cmd /c 'dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart'
        & cmd /c 'dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart'
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        Start-Sleep 30
        Write-Host "WSL is enabled now reboot the system and re-run the script to continue the installation."
    }
    



} else {
    Write-Host "Hyper-V is disabled."
    Write-Host "Enabling Hyper-V feature now"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Start-Sleep 30
    Write-Host "Hyper-V is enabled now reboot the system and re-run the script to continue the installation."
}



<#
REFERENCES USED FOR WRITING THIS SCRIPT

https://adamtheautomator.com/windows-subsystem-for-linux/#:~:text=To%20start%20using%20WSL%2C%20open,exe%20provides%20when%20starting%20up.
https://superuser.com/questions/1271682/is-there-a-way-of-installing-ubuntu-windows-subsystem-for-linux-on-win10-v170
https://stackoverflow.com/questions/61396435/how-do-i-check-the-os-architecture32-or-64-bit-using-powershell
https://renenyffenegger.ch/notes/Windows/Subsystem-for-Linux/index
https://docs.docker.com/docker-for-windows/wsl/
https://docs.microsoft.com/en-us/windows/wsl/install-win10
https://superuser.com/questions/1271682/is-there-a-way-of-installing-ubuntu-windows-subsystem-for-linux-on-win10-v170

https://wiki.ubuntu.com/WSL

https://winaero.com/export-import-wsl-linux-distro-windows-10/
#>