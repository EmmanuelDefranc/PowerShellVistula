$ErrorActionPreference = "stop"
Import-Module $PSScriptRoot\bin\ConvertTo-PsvTable.ps1 -Force
Import-Module $PSScriptRoot\bin\Get-PsvPage.ps1 -Force

Get-PsvPage -View "$PSScriptRoot\view\index.psv.xml" -Controller "$PSScriptRoot\controller\index.psv.ps1" -ArgumentList "Passed_Argument_1","Unused Argument #2" | Out-File -FilePath "$PSScriptRoot\index.html"