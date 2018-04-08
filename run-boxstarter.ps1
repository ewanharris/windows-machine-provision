<#
    An install script for setting up a Windows machine with Boxstarter

    Install Boxstarter:
        . { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

    You might need to set the execution policy using: Set-ExecutionPolicy RemoteSigned
    Run this boxstarter by calling the following from an **elevated** command-prompt:
 	    start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
        OR
        Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots

    Learn more: http://boxstarter.org/Learn/WebLauncher
#>

# Install Boxstarter
. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force



$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

$utilsModule = [Environment]::GetEnvironmentVariable("UtilsModule", "Machine")
if (-not $utilsModule) {
    $utilsModule = "$PSScriptRoot\source\Awam.Utils.psm1"
    [Environment]::SetEnvironmentVariable("UtilsModule", $utilsModule, "Machine")
}

# Import utiity related functions
Import-Module -Name "$utilsModule"

$cpModule = [Environment]::GetEnvironmentVariable("CheckpointModule", "Machine")
if (-not $cpModule) {
    $cpModule = "$PSScriptRoot\source\Awam.Checkpoint.psm1"
    [Environment]::SetEnvironmentVariable("CheckpointModule", $cpModule, "Machine")
}

# Import checkpoint related functions
Import-Module -Name "$cpModule"

$checkpointPrefix = 'BoxStarter:Checkpoint:'

# Installation related functions

function Set-BaseSettings {
    Update-ExecutionPolicy -Policy Unrestricted
    
    Disable-BingSearch
    Disable-GameBarTips
    
    $sytemDrive = Get-SystemDrive
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
    Set-TaskbarOptions -Size Large -Dock Bottom -Combine Full -Lock
    Set-TaskbarOptions -Size Large -Dock Bottom -Combine Full -AlwaysShowIconsOn
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2
    If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1
    If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
        New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
    }
    Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

}

function Enable-Features {
    # TODO: Disable on a VM somehow?
    Enable-Feature "containers"
    Enable-Feature "Microsoft-Hyper-V"
    Enable-Feature "Microsoft-Windows-Subsystem-Linux"
}

function Install-CoreApps {
    choco install 7zip.install --limitoutput
    choco install f.lux --limitoutput
    choco install firefox --limitoutput
    choco install googlechrome --limitoutput
    choco install microsoft-teams --limitoutput
    choco install sharex --limitoutput
    choco install slack --limitoutput

    # pin apps that update themselves
    choco pin add -n=firefox
    choco pin add -n=googlechrome
    choco pin add -n=sharex
    
}

function Install-CoreDevApps {

    choco install cmder --limitoutput
    choco install git.install -params '"/GitAndUnixToolsOnPath"' --limitoutput
    choco install nodejs --limitoutput
    choco install jdk8 --limitoutput
    choco install visualstudiocode --limitoutput
    choco install yarn --limitoutput

    # pin apps that update themselvesgitkraken
    choco pin add -n=docker-for-windows
    choco pin add -n=visualstudiocode

    Update-Path
}

function Install-NpmPackages {
    npm install -g titanium
    npm install -g appcelerator
    npm install -g npm-windows-upgrade
}

function Install-VisualStudio2017 {

    choco install visualstudio2017community --limitoutput

    choco pin add -n=visualstudio2017community
}

function Uninstall-Crud {
    # 3D Builder
    Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage

    # Alarms
    Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage

    # Autodesk
    Get-AppxPackage *Autodesk* | Remove-AppxPackage

    # Bing Weather, News, Sports, and Finance (Money):
    Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
    Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
    Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
    Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage

    # BubbleWitch
    Get-AppxPackage *BubbleWitch* | Remove-AppxPackage

    # Candy Crush
    Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage

    # Comms Phone
    Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage

    # Dropbox
    Get-AppxPackage *Dropbox* | Remove-AppxPackage

    # Facebook
    Get-AppxPackage *Facebook* | Remove-AppxPackage

    # Get Started
    Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage

    # Keeper
    Get-AppxPackage *Keeper* | Remove-AppxPackage

    # Mail & Calendar
    Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage

    # Maps
    Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage

    # March of Empires
    Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage

    # Messaging
    Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage

    # Minecraft
    Get-AppxPackage *Minecraft* | Remove-AppxPackage

    # Netflix
    Get-AppxPackage *Netflix* | Remove-AppxPackage

    # Office Hub
    Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage

    # One Connect
    Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage


    # People
    Get-AppxPackage Microsoft.People | Remove-AppxPackage

    # Phone
    Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage

    # Plex
    Get-AppxPackage *Plex* | Remove-AppxPackage

    # Skype (Metro version)
    Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage

    # Solitaire
    Get-AppxPackage *Solitaire* | Remove-AppxPackage

    # Sway
    Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage

    # Twitter
    Get-AppxPackage *Twitter* | Remove-AppxPackage

    # Xbox
    Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
    Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage

    # Zune Music, Movies & TV
    Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
    Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage
}


$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"

# disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Write-BoxstarterMessage "Setting user preferences and enabling features"


Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName 'BaseSettings' -SkipMessage 'Base settings are already configured'
Use-Checkpoint -Function ${Function:Enable-Features} -CheckpointName 'Features' -SkipMessage 'Features are already configured'

Write-BoxstarterMessage "Starting to install software"
# TODO: Add a flag for not installing dev things?

Use-Checkpoint -Function ${Function:Install-CoreApps} -CheckpointName 'InstallCoreApps' -SkipMessage 'Core apps are already installed'
Use-Checkpoint -Function ${Function:Install-CoreDevApps} -CheckpointName 'InstallCoreDevApps' -SkipMessage 'Core dev apps are already installed'

Use-Checkpoint -Function ${Function:Uninstall-Crud} -CheckpointName 'UninstallCrud' -SkipMessage 'Crud is alread gone! (yay)'


#Use-Checkpoint -Function ${Function:Install-VisualStudio2017} -CheckpointName 'VisualStudio2017Community' -SkipMessage 'Visual Studio 2017 Community is already installed'
#Use-Checkpoint -Function ${Function:Install-VisualStudio2017Workloads} -CheckpointName 'VisualStudio2017Workloads' -SkipMessage 'Visual Studio 2017 Workloads are already installed'

choco install chocolatey --limitoutput

# re-enable chocolatey default confirmation behaviour
Use-Checkpoint -Function ${Function:Disable-ChocolateyFeatures} -CheckpointName 'DisableChocolatey' -SkipMessage 'Chocolatey features already configured'

if (Test-PendingReboot) { 
    Invoke-Reboot 
}

Update-Path

Use-Checkpoint -Function ${Function:Install-NpmPackages} -CheckpointName 'NpmPackages' -SkipMessage 'NPM packages are already installed'

[Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

Clear-Checkpoints

Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag
$computername = "awam"
if ($env:computername -ne $computername) {
	Rename-Computer -NewName $computername
}

[Environment]::SetEnvironmentVariable("UtilsModule", '', "Machine")
[Environment]::SetEnvironmentVariable("CheckpointModule", '', "Machine")

if (Test-PendingReboot) { 
    Invoke-Reboot
}