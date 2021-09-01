function Get-Page {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [PSCustomObject[]]$ArgumentList
    )

    $PsvView = Import-Clixml -Path "$((Get-Location).Path)\.cache\$Name.xml"
    $PsvData = ."$((Get-Location).Path)\mapping\$Name.ps1" @ArgumentList

    #Injecting text into the HTML file
    $HtmlPage = @()
    foreach ($section in $PsvView) {
        #.Value - Problem witn import-clixml with enum types: https://github.com/PowerShell/PowerShell/issues/9982
        switch ($section.Language.Value) {
            "PsvData" {
                if (-not [string]::IsNullOrEmpty(($result = Invoke-Expression -Command "`$PsvData.$($section.Data)"))) {
                    $HtmlPage += $result
                }
                else {
                    Write-Host "Value is null, empty or it was not found '`$PsvData.$($section.Data)'"
                }
                #Invoke-Expression "`$psv$(($tokens.Code -split "\." | ForEach-Object {".get_Item('$_')"}) -join '')"
                break
            }
            "PsvCode" {
                # To be expanded someday
                break
            }
            "PowerShell" {
                #$script = [scriptblock]::Create($section.Data)
                try {
                    $HtmlPage += & ([scriptblock]::Create($section.Data))
                }
                catch {
                    Write-Error "Wrong PowerShell Code in the View object:`t$View`non code: `t$($section.Data).`nPowerShell Error Details below:"
                    throw $PSItem
                }
                break
            }
            "HTML" {
                $HtmlPage += $section.Data
                break
            }
        }
    }
    return $HtmlPage
}