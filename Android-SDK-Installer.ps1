# Automated Android SDK installer for Windows 10/11 (CLI only)
# Configured specifically for Morphe ecosystem requirements

# Verify JDK 25 installation as required by Morphe
Write-Host "Checking for JDK 25 installation..." -ForegroundColor Cyan
try {
    $javaOutput = & java -version 2>&1
    $javaStr = $javaOutput -join " "
    
    if ($javaStr -match 'version\s+"?(25(\.[0-9]+)*)') {
        Write-Host "Success: JDK 25 detected." -ForegroundColor Green
    } else {
        Write-Error "Morphe requires JDK 25, but a different version was found. Output: $javaStr"
        exit 1
    }
} catch {
    Write-Error "Java is not detected on this system. Please ensure JDK 25 is installed and added to your Environment Variables."
    exit 1
}

# Setting up directories (Targeting AppData\Local\Android)
$SdkDir = "$env:LOCALAPPDATA\Android"
$CmdlineLatestDir = "$SdkDir\cmdline-tools\latest"
$ZipPath = "$env:TEMP\commandlinetools-win.zip"
$ExtractPath = "$env:TEMP\android_cmdline_temp"

# Dynamically fetch the latest command-line tools URL from the Android Developer page
Write-Host "Fetching the latest download link from Google..." -ForegroundColor Cyan
try {
    $StudioPage = Invoke-WebRequest -Uri "https://developer.android.com/studio" -UseBasicParsing -ErrorAction Stop
    $UrlPattern = "https://dl\.google\.com/android/repository/commandlinetools-win-[0-9]+_latest\.zip"
    $Match = [regex]::Match($StudioPage.Content, $UrlPattern)

    if ($Match.Success) {
        $DownloadUrl = $Match.Value
        Write-Host "Found latest URL: $DownloadUrl" -ForegroundColor Green
    } else {
        Write-Host "Failed to dynamically fetch URL. Falling back to a known stable version." -ForegroundColor Yellow
        $DownloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    }
} catch {
    Write-Error "Failed to reach Google servers to fetch the URL: $_"
    exit 1
}

Write-Host "Reading initial configuration..." -ForegroundColor Cyan

# Step 1: Create the Android SDK directory structure
if (!(Test-Path $CmdlineLatestDir)) {
    Write-Host "Setting up the Android SDK directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $CmdlineLatestDir | Out-Null
}

# Step 2: Download the command-line tools from Google
Write-Host "Downloading Android SDK Command-line Tools..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -ErrorAction Stop
} catch {
    Write-Error "Failed to download the SDK zip file: $_"
    exit 1
}

# Step 3: Extract and organize files into the 'latest' folder
Write-Host "Extracting files..." -ForegroundColor Yellow
if (Test-Path $ExtractPath) { Remove-Item -Recurse -Force $ExtractPath }

Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractPath)
} catch {
    Write-Error "Failed to extract the downloaded zip file: $_"
    exit 1
}

Write-Host "Organizing directory structure..." -ForegroundColor Yellow
Copy-Item -Path "$ExtractPath\cmdline-tools\*" -Destination $CmdlineLatestDir -Recurse -Force

# Clean up temporary files
Remove-Item $ZipPath -Force
Remove-Item $ExtractPath -Recurse -Force

# Step 4: Configure Windows Environment Variables
Write-Host "Configuring Environment Variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $SdkDir, "User")
Write-Host "  -> ANDROID_HOME set to $SdkDir" -ForegroundColor Green

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$NewPaths = @(
    "$CmdlineLatestDir\bin",
    "$SdkDir\platform-tools",
    "$SdkDir\build-tools\34.0.0"
)

$PathUpdated = $false
foreach ($Path in $NewPaths) {
    if ($UserPath -notmatch [regex]::Escape($Path)) {
        $UserPath += ";$Path"
        $PathUpdated = $true
        Write-Host "  -> Appended $Path to System PATH" -ForegroundColor Green
    }
}

if ($PathUpdated) {
    [Environment]::SetEnvironmentVariable("Path", $UserPath, "User")
}

# Refresh variables in the current terminal session to use sdkmanager immediately
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:ANDROID_HOME = $SdkDir

# Step 5: Automatically accept SDK licenses and install required tools
Write-Host "Accepting SDK licenses and installing Build-Tools 34.0.0 & Platform-Tools..." -ForegroundColor Yellow

$SdkManagerPath = "$CmdlineLatestDir\bin\sdkmanager.bat"
$env:_JAVA_OPTIONS = "--enable-native-access=ALL-UNNAMED"

try {
    $AutoYes = "y`n" * 50
    $AutoYes | & $SdkManagerPath --licenses | Out-Null
    
    & $SdkManagerPath "platform-tools" "build-tools;34.0.0" -ErrorAction Stop
} catch {
    Write-Error "Failed to install SDK components via sdkmanager: $_"
    exit 1
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Installation completed successfully." -ForegroundColor Green
Write-Host "Installed components:"
Write-Host "- cmdline-tools (sdkmanager)"
Write-Host "- platform-tools (adb)"
Write-Host "- build-tools 34.0.0 (aapt2, apksigner, zipalign, d8)"
Write-Host ""
Write-Host "IMPORTANT: Please close this PowerShell window and open a new session to apply environment variables." -ForegroundColor Red
Write-Host "Once opened, verify the installation by running: d8 --version" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# Keep the window open until the user presses Enter
$null = Read-Host "`nPress 'Enter' to close this window..."