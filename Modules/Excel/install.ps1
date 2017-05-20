$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
$UserModuleDir = $env:PSModulePath -split ";" | ?{ $_ -like "${env:USERPROFILE}*" }
$CurrentModuleDir = Join-Path $UserModuleDir (Get-Item $ScriptDir).BaseName

$mklinkArgs = @()
$mklinkArgs += [PSCustomObject]@{"source"="$ScriptDir"; "target"="$CurrentModuleDir"}

$Command = "/c cd /d `"$ScriptDir`""
$mklinkArgs | %{ $Command += " `& mklink /d `"$($_.target)`" `"$($_.source)`"" }

Start-Process cmd -Verb Runas -WindowStyle Hidden -ArgumentList $Command