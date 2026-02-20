function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO",

        [Parameter()]
        [string]$LogPath = "$PSScriptRoot\..\..\logs\EnterpriseADToolkit.log"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Level] $Message"

    Write-Verbose $entry

    try {
        New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null
        Add-Content -Path $LogPath -Value $entry
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}
