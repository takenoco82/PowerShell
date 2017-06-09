# Load
Split-Path $MyInvocation.MyCommand.Path -Parent | Push-Location
Get-ChildItem *.ps1 | % { . $_ }
Pop-Location

Set-Alias -Name peso -Value Start-InteractiveFilter

Export-ModuleMember -Function Start-InteractiveFilter
