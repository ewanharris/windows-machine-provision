function Get-OSInformation {
    $osInfo = Get-WmiObject -class Win32_OperatingSystem `
        | Select-Object -First 1

    return ConvertFrom-String -Delimiter \. -PropertyNames Major, Minor, Build  $osInfo.version
}

function Test-IsOSWindows10 {
    $osInfo = Get-OSInformation

    return $osInfo.Major -eq 10
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

function Get-DataDrive {
    $driveLetter = Get-SystemDrive

    if ((Test-Path env:\BoxStarter:DataDrive) -and (Test-Path $env:BoxStarter:DataDrive)) {
        $driveLetter = $env:BoxStarter:DataDrive
    }

    return $driveLetter
}

function Enable-ChocolateyFeatures {
    choco feature enable --name=allowGlobalConfirmation
}

function Disable-ChocolateyFeatures {
    choco feature disable --name=allowGlobalConfirmation
}

function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Enable-Feature {
    param
   (
       [Parameter(Mandatory = $true)]
       [string]
       $FeatureName
   )

   Try {
       Enable-WindowsOptionalFeature -Online -FeatureName "$FeatureName" -All -NoRestart
       Write-BoxstarterMessage "Enabled $FeatureName"
   }
   Catch {
       $ErrorMessage = $_.Exception.Message
       Write-BoxstarterMessage "Unable to enable $Featurename got error $ErrorMessage"
   }
   
}