function Get-PsvPage {
    param(
        [string]$View,

        [string]$Controller,

        [string[]]$ArgumentList
    )

    $Global:PsvIcon = .$PSScriptRoot\Register-PsvIcon.ps1
    $PsvView = Import-Clixml -Path $View
    $PsvData = .$Controller @ArgumentList

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
                    throw "Value not found '`$PsvData.$($section.Data)'"
                }
                #Invoke-Expression "`$psv$(($tokens.Code -split "\." | ForEach-Object {".get_Item('$_')"}) -join '')"
                break
            }
            "PsvCode" {
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