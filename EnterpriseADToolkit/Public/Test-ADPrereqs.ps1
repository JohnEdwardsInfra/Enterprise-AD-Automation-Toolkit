function Test-ADPrereqs {
    [CmdletBinding()]
    param()

    Write-Verbose "Checking prerequisites..."

    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT (AD module) first."
    }

    Import-Module ActiveDirectory -ErrorAction Stop

    $domain = Get-ADDomain -ErrorAction Stop
    Write-Verbose "Connected to domain: $($domain.DNSRoot)"

    [pscustomobject]@{
        ActiveDirectoryModule = $true
        Domain               = $domain.DNSRoot
        Status               = "OK"
    }
}
