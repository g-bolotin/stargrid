# Developed by Galit Bolotin
# 7/17/2025 v1.0

# Info needed to check uptime:
# IP
# Current date
# Current time
# Info needed to be retrieved after successful ping:
# System name
# MAC
# Current date
# Current time
# Info needed after ping failure:
# Retry number

# Let's start by testing on a PC :)

Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String[]]$Systems,
    
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('calm','rush','night')]
    [String]$PingFrequency,

    [String]$KillTime = "never"
)

# TODO:
# If ping comes back successful, ask that system for its information, reset retry value
# If retry value wasn't already 0, store "back online" date/time
# If ping fails, check retry value, send appropriate warning, increment the retry
# Retry 0 = failed first ping
# Retry 3 = soft failure
# Retry 5 = hard failure, notify


# TODO: Need some way to make it persistent, like task scheduler

# Monitoring logic
# Ping system, get host name and online status, and log the data

Start-Job -Name "Heartbeat" -ScriptBlock{
    # Pass in variables, otherwise they get lost when the job starts in a new pwsh instance
    param($Systems, $PingFrequency, $KillTime)

    # Monitoring logic: get timestamp, IP, host name, online status, and log them.
    # TODO: change this to store data in a database for dashboard use and Excel export
    function Ping-Systems{
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    
        foreach($System in $Systems){
            $ping = Test-Connection $System -Count 1 -Quiet
            try {
                    $hostName = (Resolve-DnsName -Name $System -ErrorAction Stop).NameHost
                } catch {
                    $hostName = "Unresolved"
                }
            $status = if ($ping) {"Online"} else {"Offline"}
            "$timestamp | $System | $hostName | $status" | Out-File -Append $logFile
        }
    }

    $date = Get-Date -format "yyyy-MM-dd"
    $logPath = "./logs/"
    $logFile = "$($logPath + 'heartbeat-' + $date + '.log')"

    if (-not (Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath | Out-Null # Don't care about DirectoryInfo object, send to void
    }

    Write-Host "created log file, starting heartbeat"
    "Initiating heartbeat at $PingFrequency rate." | Out-File -Append $logFile
    $monitoring = $True
    
    # Persistent monitoring, no end date/time
    if ($KillTime -ne "never") {
        try {
            # Convert specified kill time from string into datetime object
            $ktime = [datetime]::ParseExact($KillTime, "yyyy-MM-dd HH:mm:ss", $null)
            "Kill Time set to: $ktime" | Out-File -Append $logFile

            while ($monitoring -and (Get-Date) -lt $ktime) {
                Ping-Systems
                Start-Sleep -Seconds 60
            }

            "Kill Time reached at: $(Get-Date)" | Out-File -Append $logFile
        }
        catch {
            "Invalid Kill Time format. Please use 'yyyy-MM-dd HH:mm:ss'." | Out-File -Append $logFile
        }
    }
    else {
        "Kill time set to 'never'. Running indefinitely." | Out-File -Append $logFile
        while($monitoring){
            Ping-Systems
            Start-Sleep -Seconds 60
        }
    }
} -ArgumentList $Systems, $PingFrequency, $KillTime # Pass params into the job explicitly so they don't get lost
