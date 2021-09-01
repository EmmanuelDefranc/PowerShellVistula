$ErrorActionPreference = "stop"
Import-Module $PSScriptRoot\bin\Invoke-PsvParser.ps1 -Force

Invoke-PsvParser -File "$PSScriptRoot\html\index.psv.html" | Export-Clixml -Path "$PSScriptRoot\View\index.psv.xml"