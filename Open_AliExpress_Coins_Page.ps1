# Define the URL and wait time
$url = "https://www.aliexpress.com/p/coin-pc-index/index.html"
$waitTime = 60
$scriptToCheck = "C:\Users\Admin\Documents\Powershell Scripts\Open_AE_Mobile_Coins_Webapp.ps1"

# Function to check for internet connectivity
function Test-InternetConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

# Function to wait until internet is available
function Wait-ForInternet {
    while (-not (Test-InternetConnection)) {
        Write-Host "No internet connection. Retrying in 30 seconds..."
        Start-Sleep -Seconds 30
    }
    Write-Host "Internet connection is available."
}

# Function to start a browser for the URL and return the process
function Start-BrowserForUrl {
    param (
        [string]$browserPath,
        [string]$url
    )
    return Start-Process $browserPath -ArgumentList $url -PassThru
}

# Function to check if a specific PowerShell script is running
function Is-ScriptRunning {
    param (
        [string]$scriptName
    )
    $runningPowerShellProcesses = Get-Process -Name "powershell" -ErrorAction SilentlyContinue
    foreach ($process in $runningPowerShellProcesses) {
        try {
            $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
            if ($commandLine -like "*$scriptName*") {
                return $true
            }
        } catch {
            Write-Error "Failed to retrieve command line for process ID $($process.Id). $_"
        }
    }
    return $false
}

# Wait for internet connection
Wait-ForInternet

# Start all browsers for the URL
$allProcesses = @()
$allProcesses += Start-BrowserForUrl "C:\Program Files\Google\Chrome\Application\chrome.exe" $url
$allProcesses += Start-BrowserForUrl "C:\Users\Admin\AppData\Local\Chromium\Application\chrome.exe" $url
$allProcesses += Start-BrowserForUrl "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" $url
$allProcesses += Start-BrowserForUrl "msedge.exe" $url

# Wait for the specified time
Start-Sleep -Seconds $waitTime

# Check if the script is running and close browsers if not
if (-not (Is-ScriptRunning $scriptToCheck)) {
    foreach ($process in $allProcesses) {
        $process | Stop-Process -Force
    }
}
Stop-Process -Name "msedge" -Force