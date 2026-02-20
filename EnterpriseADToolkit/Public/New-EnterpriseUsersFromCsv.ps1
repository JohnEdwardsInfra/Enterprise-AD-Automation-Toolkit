function New-EnterpriseUsersFromCsv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter()]
        [SecureString]$DefaultPassword,

        [Parameter()]
        [string]$LogPath = (Join-Path $PSScriptRoot "..\..\logs\EnterpriseADToolkit.log")
    )

    # AD module check (lab-safe fail)
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT Active Directory tools to use this function."
    }

    Import-Module ActiveDirectory -ErrorAction Stop

    if (-not $DefaultPassword) {
        # Lab-safe default
        $DefaultPassword = ConvertTo-SecureString "P@ssw0rd!ChangeMe" -AsPlainText -Force
    }

    Write-Log -Message "Starting bulk user provisioning from CSV: $CsvPath" -Level "INFO" -LogPath $LogPath

    $users = Import-Csv -Path $CsvPath

    foreach ($u in $users) {
        try {
            foreach ($field in @("GivenName","Surname","SamAccountName","UserPrincipalName","OU")) {
                if (-not $u.$field) { throw "Missing required field '$field' in CSV row." }
            }

            $existing = Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue
            if ($existing) {
                Write-Log -Message "SKIP (exists): $($u.SamAccountName)" -Level "WARN" -LogPath $LogPath
                continue
            }

            $enabled = $true
            if ($u.PSObject.Properties.Name -contains "Enabled" -and $null -ne $u.Enabled) {
                $enabled = [System.Convert]::ToBoolean($u.Enabled)
            }

            $params = @{
                Name                  = "$($u.GivenName) $($u.Surname)"
                GivenName             = $u.GivenName
                Surname               = $u.Surname
                SamAccountName        = $u.SamAccountName
                UserPrincipalName     = $u.UserPrincipalName
                Path                  = $u.OU
                Enabled               = $enabled
                AccountPassword       = $DefaultPassword
                ChangePasswordAtLogon = $true
            }

            if ($PSCmdlet.ShouldProcess($u.SamAccountName, "Create AD user in $($u.OU)")) {
                New-ADUser @params -ErrorAction Stop
                Write-Log -Message "CREATE: $($u.SamAccountName)" -Level "INFO" -LogPath $LogPath
            }
        }
        catch {
            Write-Log -Message "ERROR processing $($u.SamAccountName): $($_.Exception.Message)" -Level "ERROR" -LogPath $LogPath
        }
    }

    Write-Log -Message "Bulk provisioning completed." -Level "INFO" -LogPath $LogPath
}
