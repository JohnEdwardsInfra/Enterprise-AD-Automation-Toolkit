@{

# Script module or binary module file associated with this manifest.
RootModule = 'EnterpriseADToolkit.psm1'

# Version number of this module.
ModuleVersion = '0.1.0'

# Supported PSEditions
CompatiblePSEditions = @('Desktop', 'Core')

# ID used to uniquely identify this module
GUID = 'ad5f0d6a-4585-4ab4-870e-123bd061fc5e'

# Author of this module
Author = 'John Edwards'

# Company or vendor of this module
CompanyName = 'Community'

# Copyright statement for this module
Copyright = '(c) John Edwards. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Enterprise Active Directory automation toolkit (lab safe) with logging, validation, and modular design.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Functions to export from this module
FunctionsToExport = @(
  'Test-Toolkit',
  'Test-ADPrereqs',
  'New-EnterpriseUsersFromCsv'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{
    PSData = @{
        Tags = @('PowerShell','ActiveDirectory','Automation','Infrastructure','Windows','Enterprise')
        LicenseUri = ''
        ProjectUri = ''
        ReleaseNotes = 'Initial release: module foundation + health checks + CSV bulk user provisioning.'
    }
}

}
