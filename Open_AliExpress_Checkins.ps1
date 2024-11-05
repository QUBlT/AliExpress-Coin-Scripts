# Define the URLs and wait time
$urls = @(
"https://s.click.aliexpress.com/e/_DEqVQvx",
"https://s.click.aliexpress.com/e/_DnnocKl", 
"https://s.click.aliexpress.com/e/_DkBTtNJ", 
"https://s.click.aliexpress.com/e/_Dntpbyz", 
"https://s.click.aliexpress.com/e/_DBT23G5", 
"https://s.click.aliexpress.com/e/_DEFdVrh", 
"https://s.click.aliexpress.com/e/_DlfIOxz", 
"https://s.click.aliexpress.com/e/_DEWGRJ7", 
"https://s.click.aliexpress.com/e/_DEEtXvN",
"https://s.click.aliexpress.com/e/_DkopTOr",
"https://s.click.aliexpress.com/e/_Dl2L7VH", 
"https://s.click.aliexpress.com/e/_Dmp5Q8J", 
"https://s.click.aliexpress.com/e/_DklrTmJ", 
"https://s.click.aliexpress.com/e/_DcJtNQP", 
"https://s.click.aliexpress.com/e/_DEFdVrh", 
"https://s.click.aliexpress.com/e/_DlfIOxz", 
"https://s.click.aliexpress.com/e/_DnegNKP"
)
$waitTime = 240
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

# Function to start a browser for each URL and return the processes
function Start-BrowserForUrls {
    param (
        [string]$browserPath,
        [array]$urls
    )
    $processes = @()
    foreach ($url in $urls) {
        $processes += Start-Process $browserPath -ArgumentList $url -PassThru
        Start-Sleep -Seconds 8
    }
    return $processes
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

# Start all browsers for each URL
$allProcesses = @()
$allProcesses += Start-BrowserForUrls "C:\Program Files\Google\Chrome\Application\chrome.exe" $urls
$allProcesses += Start-BrowserForUrls "C:\Users\Admin\AppData\Local\Chromium\Application\chrome.exe" $urls
$allProcesses += Start-BrowserForUrls "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" $urls
$allProcesses += Start-BrowserForUrls "msedge.exe" $urls

# Wait for the specified time
Start-Sleep -Seconds $waitTime

# Check if the script is running and close browsers if not
if (-not (Is-ScriptRunning $scriptToCheck)) {
    foreach ($process in $allProcesses) {
        $process | Stop-Process -Force
    }
}
Stop-Process -Name "msedge" -Force
Stop-Process -Name "C:\Program Files\Google\Chrome\Application\chrome.exe" -Force
Stop-Process -Name "C:\Users\Admin\AppData\Local\Chromium\Application\chrome.exe" -Force
Stop-Process -Name "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" -Force