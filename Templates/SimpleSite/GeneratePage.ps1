$ErrorActionPreference = "stop"
Import-Module PowerShellVistula -Force

$ParsedHtmlFiles = Get-ChildItem -Path "$PSScriptRoot\.cache\*.xml"

if ($PSScriptRoot) {
}