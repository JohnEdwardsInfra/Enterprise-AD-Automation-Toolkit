function New-EnterpriseUsersFromCsv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter()]
        [SecureString]$DefaultPassword,

        [Parameter()]
        [string]$LogPath = "$PSScriptRoot\..\..\logs\EnterpriseADToolkit.log",
        
        [Parameter()]
        [switch]$PreviewOnly
    )

    # AD module check (allow PreviewOnly to still work)
    $adAvailable = [bool](Get-Module -ListAvailable -Name ActiveDirectory)

    if (-not $adAvailable -and -not $PreviewOnly) {
    throw "ActiveDirectory module not found. Install RSAT Active Directory tools or run with -PreviewOnly."
    }

    if ($adAvailable) {
    Import-Module ActiveDirectory -ErrorAction Stop
    }

    Write-Log -Message "Starting bulk user provisioning from CSV: $CsvPath" -Level "INFO" -LogPath $LogPath

    $users = Import-Csv -Path $CsvPath

    if ($PreviewOnly) {
    Write-Log -Message "PreviewOnly enabled. No AD changes will be made." -Level "WARN" -LogPath $LogPath

    $preview = foreach ($u in $users) {
        foreach ($field in @("GivenName","Surname","SamAccountName","UserPrincipalName","OU")) {
            if (-not $u.$field) { throw "Missing required field '$field' in CSV row." }
        }

        [pscustomobject]@{
            Name              = "$($u.GivenName) $($u.Surname)"
            SamAccountName    = $u.SamAccountName
            UserPrincipalName = $u.UserPrincipalName
            OU                = $u.OU
            Enabled           = if ($u.PSObject.Properties.Name -contains "Enabled") { $u.Enabled } else { $true }
        }
    }

    return $preview
}


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
