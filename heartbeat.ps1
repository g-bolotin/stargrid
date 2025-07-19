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

    [String]$KillTime = "00:00:00"
)

# Execute ping
# If ping comes back successful, ask that system for its information, reset retry value
# If retry value wasn't already 0, store "back online" date/time
# If ping fails, check retry value, send appropriate warning, increment the retry
# Retry 0 = failed first ping
# Retry 3 = soft failure
# Retry 5 = hard failure, notify



#If(Test-Path $logFile){
# if log file exists, append to it
# Doesnt exist, create and append
#}

# Need some way to make it persistent, like task scheduler

Start-Job -Name "Heartbeat" -ScriptBlock{
    $date = Get-Date -format "yyyy-MM-dd"
    $logPath = "./logs/"
    $logFile = "$($logPath + 'heartbeat-' + $date + '.log')"

    "Initiating heartbeat at $PingFrequency rate." | Out-File -Append $logFile

    $monitoring = $True
    while($monitoring){
        $time = Get-Date -Format "HH:mm:ss"
        If($time -eq $KillTime){
            $monitoring = $False
        }
        $timestamp = $date = Get-Date -format "yyyy-MM-dd"
    }
}
