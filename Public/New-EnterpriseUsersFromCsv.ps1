[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [Parameter()]
    [SecureString]$DefaultPassword
)

. "$PSScriptRoot\..\Private\Write-Log.ps1"

Import-Module ActiveDirectory -ErrorAction Stop

if (-not $DefaultPassword) {
    $DefaultPassword = ConvertTo-SecureString "P@ssw0rd!ChangeMe" -AsPlainText -Force
}

Write-Log -Message "Starting bulk user provisioning from $CsvPath" -Level "INFO"

$users = Import-Csv $CsvPath

foreach ($u in $users) {
    try {
        foreach ($field in @("GivenName","Surname","SamAccountName","UserPrincipalName","OU")) {
            if (-not $u.$field) { throw "Missing required field '$field' in CSV row." }
        }

        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Log -Message "SKIP (exists): $($u.SamAccountName)" -Level "WARN"
            continue
        }

        $params = @{
            Name                  = "$($u.GivenName) $($u.Surname)"
            GivenName             = $u.GivenName
            Surname               = $u.Surname
            SamAccountName        = $u.SamAccountName
            UserPrincipalName     = $u.UserPrincipalName
            Path                  = $u.OU
            Enabled               = $true
            AccountPassword       = $DefaultPassword
            ChangePasswordAtLogon = $true
        }

        if ($PSCmdlet.ShouldProcess($u.SamAccountName, "Create AD User")) {
            New-ADUser @params -ErrorAction Stop
            Write-Log -Message "CREATE: $($u.SamAccountName)" -Level "INFO"
        }
    }
    catch {
        Write-Log -Message "ERROR processing $($u.SamAccountName): $($_.Exception.Message)" -Level "ERROR"
    }
}

Write-Log -Message "Bulk provisioning completed." -Level "INFO"
Write-Host "Done. Log written to logs\EnterpriseADToolkit.log" -ForegroundColor Green
