<# 
    URL to download the VS installer executable from, 
    found by digging through the source of the "Thank You",
    download page.
#>
$url = "https://aka.ms/vs/15/release/vs_community.exe"
# Where we want to download the file to
$output = "$PSScriptRoot\vs_community.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Path tp the Visual Studio install script
$installerFile = "$PSScriptRoot\vs-install-config.json"

& "$output" --in "$installerFile"