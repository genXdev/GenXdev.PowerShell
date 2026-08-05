
@('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Utility') | Microsoft.PowerShell.Core\Import-Module
$extra = [IO.Path]::GetFullPath("$($MyInvocation.MyCommand.Module.ModuleBase)\lib")

if (-not ("$Env:Path".Contains(";$extra"))) {

    $Env:Path = "$($Env:Path);$extra"
}

Microsoft.PowerShell.Core\Get-Module GenXdev.AI, GenXdev.Coding, GenXdev.Console, GenXdev.Data, GenXdev.FileSystem, GenXdev.Helpers, GenXdev.Media, GenXdev.Queries, GenXdev.Webbrowser, GenXdev.Windows -ErrorAction SilentlyContinue |
Microsoft.PowerShell.Core\ForEach-Object Name |
Microsoft.PowerShell.Utility\Select-Object -Unique |
Microsoft.PowerShell.Core\ForEach-Object {

    $null = PowerShellGet\Uninstall-Module -Name $_ -Force -Confirm:$False -AllVersions
}
