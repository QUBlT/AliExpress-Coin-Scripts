# Define the URL and wait time
$url = "https://m.aliexpress.com/p/coin-index/index.html"
$waitTime = 240
Start-Sleep -Seconds 10
# Define mobile user agent
$mobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1"
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
# Function to start a browser with mobile user agent and return the process
function Start-Browser {
    param ([string]$browserPath)
    $arguments = '--user-agent="' + $mobileUserAgent + '" ' + $url
    try {
        $process = Start-Process $browserPath -ArgumentList $arguments -PassThru
        return $process
    } catch {
        Write-Host "Failed to start $browserPath"
        return $null
    }
}
# Wait for internet connection
Wait-ForInternet
# Start browsers one by one
$processes = @()
$browsers = @("C:\Program Files\Google\Chrome\Application\chrome.exe", "C:\Users\Admin\AppData\Local\Chromium\Application\chrome.exe", "C:\Program Files\Google\Chrome Beta\Application\chrome.exe","msedge.exe")
foreach ($browser in $browsers) {
    $process = Start-Browser $browser
    if ($process -ne $null) {
        $processes += $process
        Write-Host "Started $browser. Waiting for 30 seconds before launching the next browser..."
        Start-Sleep -Seconds 30
    }
}
# Optionally add other browsers


# Wait for the specified time
Start-Sleep -Seconds $waitTime

# Close all browsers instantly
foreach ($process in $processes) {
    if ($process -and !$process.HasExited) {
        try {
            $process.Kill()
        } catch {
            Write-Host "Failed to close process: $($process.Name)"
        }
    }
}

# Force close any remaining browser processes instantly
$browserProcessNames = @("chrome", "chromium", "msedge")
foreach ($name in $browserProcessNames) {
    Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.Kill()
        } catch {
            Write-Host "Failed to close process: $($_.Name)"
        }
    }
}