# Check for previously saved key and either setApiKey or just push the package
# Also, assume nuget.exe is here after a retail build that generated the package

param (
    [string]$apiKey = "",
    [string]$nuspec = "",
    [string]$package = "",
    [string]$packageSource = "https://www.nuget.org/api/v2/package"
)

# nuget.exe not found
if (![System.IO.File]::Exists(".\nuget.exe")) {
    Write-Host Downloading nuget.exe....
    (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", "nuget.exe")
}

# If api key provided, set it [again]
if (![string]::IsNullOrEmpty($apiKey)) {
    .\nuget.exe setApiKey $apiKey -Source $packageSource
}

# Key not found
if (-not (Get-Content $env:appdata\NuGet\NuGet.Config | Select-String "$packageSource" -quiet)) {
    Write-Host -ForegroundColor Red "apiKey not found.";
    exit;
}

# Packing
if (![string]::IsNullOrEmpty($nuspec)) {
    .\nuget.exe pack $nuspec
}

# Pushing
if (![string]::IsNullOrEmpty($package)) {
    .\nuget.exe push $package -Source "$packageSource"
}
