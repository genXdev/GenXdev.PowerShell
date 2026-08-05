Microsoft.PowerShell.Utility\Add-Type -Path "C:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.27.2026\bin\net10.0-windows10.0.26100.0\win-x64\GenXdev.dll" -v

$s = [IO.File]::ReadAllText("C:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.27.2026\GenXdev.psd1")
$s = $s.Replace("'lib\", "'.\bin\net10.0-windows10.0.26100.0\win-x64\")
[IO.File]::WriteAllText('C:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.27.2026\_GenXdev.debug.psd1', $s);

Microsoft.PowerShell.Core\Import-Module "C:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.27.2026\_GenXdev.debug.psd1"

& "C:\Users\renev\Documents\PowerShell\Microsoft.VSCode.Debug_profile.ps1"

