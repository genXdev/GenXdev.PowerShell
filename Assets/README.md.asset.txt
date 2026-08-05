# Powershell script development and execution environment
<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

## Issues
## Todoos
## Ideas
## Features
## Release notes

## Description
- The scripts in these folders, should be seen as personalisations of the default Windows commandshell.
- Are written by the author for his personal use only.
- No support is provided.
- These scripts are used to increase productivity and should never be shipped with any product.

## Guidelines
- Don't store any 'secrets' in script files
- Press F5 from within VSCode to start debugging

## Workspace Overview

This workspace primarily consists of the `./Scripts` folder and all the `./Modules/GenXdev*/*.*.*/` modules. These are the core components of the project.

Each module directory has at least:

- .\Functions\*\*.ps1   all the cmdlet functions
- .\Tests\*\*.Tests.ps1 all the cmdlet unit-tests
- .\README.md           all the info about the Module and it's cmdlets
