# Enterprise AD Automation Toolkit

A modular PowerShell toolkit for automating common enterprise Active Directory tasks (user provisioning, OU creation, group membership) with logging, validation, and safe defaults.

## Why this exists
Enterprise Windows environments require repeatable, auditable operations. This toolkit demonstrates patterns used in large-scale environments: modular scripts, input validation, logging, and idempotent behavior where practical.

## Features
- Bulk user creation from CSV
- Bulk group membership from CSV
- OU structure creation from JSON
- Pre-flight checks for required modules/permissions
- Logging to file + console

## Requirements
- Windows PowerShell 5.1+ or PowerShell 7+ (best effort)
- RSAT ActiveDirectory module
- Permissions appropriate to your domain/lab

## Quick Start
1. Clone repo
2. Open PowerShell as a user with AD permissions
3. Run pre-reqs test:
   ```powershell
   .\src\Public\Test-ADPrereqs.ps1

