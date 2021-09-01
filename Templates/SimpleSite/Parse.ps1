$ErrorActionPreference = "stop"
Import-Module Vistula -Force

<#
$InputFilePath = "$PSScriptRoot\html\index.psv.html"

[pscustomobject][ordered]@{
    Header = @{
        Hash = Get-FileHash $InputFilePath
    }
    Content = Invoke-VistulaParser -File $InputFilePath
} | Export-Clixml -Path "$PSScriptRoot\.cache\index.psv.xml"
#>

foreach ($item in Get-ChildItem -Path "$PSScriptRoot\html\*.html") {
    Invoke-VistulaParser -File $item.FullName | Export-Clixml -Path "$PSScriptRoot\.cache\$($item.BaseName).xml"
}
