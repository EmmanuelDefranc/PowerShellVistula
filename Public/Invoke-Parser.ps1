function Invoke-Parser {

    param (
        [Parameter(Mandatory)]
        [string]$File
    )
    
    try {
        $Stream = [System.IO.StreamReader]::new((Resolve-Path -Path $File).Path)
    }
    catch {
        throw "The file '$File' does not exist"
    }

    enum Language {
        PsvData = 0
        PsvCode = 1
        PowerShell = 2
        HTML = 3
    }

    $Cursor = @{
        Line = 1
        Column = 1
    }
    $ParseTree = [System.Collections.ArrayList]::new()
    $Token = @{}

    function Reset-PsvToken {
        $Token.Language = $null
        $Token.Data = [string]::Empty
    }

    function Set-PsvToken {
        
        param(
            [Parameter(Mandatory = $true)]
            [Language]$Language,

            [string]$String
        )

        if ($Token.Language -ne $Language) {
            if ($null -ne $Token.Language) {
                Add-PsvTokenToTree
            }
            Reset-PsvToken
            $Token.Language = $Language
        }

        if ($null -ne $String) {
            $Token.Data += $String
        }

    }

    function Add-PsvTokenToTree {
        [void]$ParseTree.Add($Token.Clone())
    }

    function Read-PsvData {
        while(-not $Stream.EndOfStream -and [char]$Stream.Peek() -match "[a-zA-Z0-9\.]") {
            $value = $Stream.Read()
            Set-PsvToken -Language ([Language]::PsvData) -String ([char]$value)
            Set-CursorPosition -Character $value
        }
    }

    function Read-PsvCode {
        $value = $Stream.Read() #Read the ':'
        Set-CursorPosition -Character $value
        $value = $Stream.Read() #Read the next char. This should be a '{'
        Set-CursorPosition -Character $value
        if ([char]$value -ne "{") {
            Stop-PsvParser -Message "Error. Expecting '{' character."
        }
        $openParenthesis = 0

        while (-not $Stream.EndOfStream) {
            $value = $Stream.Read()
            Set-CursorPosition -Character $value
            switch ([char]$value) {
                "{" {
                    $openParenthesis += 1
                }
                "}" {
                    $openParenthesis -= 1
                }
            }
            if ($openParenthesis -ge 0) {
                Set-PsvToken -Language ([Language]::PsvCode) -String ([char]$value)
            }
            else {
                break
            }
        }

        if ($openParenthesis -ge 0) {
            Stop-PsvParser -Message "PSV Code not properly closed. Expecting '}' character."
        }
    }

    function Read-PsvPowerShell {
        $value = $Stream.Read()
        Set-CursorPosition -Character $value
        $openParenthesis = 0

        while(-not $Stream.EndOfStream) {
            $value = $stream.Read()
            Set-CursorPosition -Character $value
            switch ([char]$value) {
                "{" {
                    $openParenthesis += 1
                }
                "}" {
                    $openParenthesis -= 1
                }
            }
            if ($openParenthesis -ge 0) {
                Set-PsvToken -Language ([Language]::PowerShell) -String ([char]$value)
            }
            else {
                break
            }
        }

        if ($openParenthesis -ge 0) {
            Stop-PsvParser -Message "PowerShell Code not properly closed. Expecting '}' character."
        }
    }

    function Read-PsvHtml {
        while(-not $Stream.EndOfStream -and [char]$Stream.Peek() -ne "`$") {
            $value = $Stream.Read()
            Set-PsvToken -Language ([Language]::HTML) -String ([char]$value)
            Set-CursorPosition -Character $value
        }
    }

    function Stop-PsvParser {
        param(
            [string]$Message
        )
        $Stream.Close()
        $Stream.Dispose()
        if (-not [string]::IsNullOrEmpty($Message)) {
            throw "$Message. At Line: $($Cursor.Line), Col: $($Cursor.Column)"
        }
    }

    function Set-CursorPosition {
        param(
            [int]$Character
        )

        switch ($Character) {
            10 {
                $Cursor.Line +=  1
                $Cursor.Column = 1
                break
            }
            9 {
                $Cursor.Column += 4
                break
            }
            default {
                $Cursor.Column++
            }
        }
    }

    Reset-PsvToken
    while (-not $Stream.EndOfStream) {
        $character = [char]$Stream.Peek()

        if ($character -eq "`$") {
            Set-CursorPosition -Character $Stream.Read() #Ignore first $ sign
            switch ([char]$Stream.Peek()) {
                #Ignore $ character
                "`$" {
                    Set-CursorPosition -Character $Stream.Read()
                    Set-PsvToken -Language ([Language]::HTML) -String "`$"
                    break
                }
                #Psv Data
                {$PSItem -match "[a-zA-Z0-9]"} {
                    Read-PsvData
                }
                #Psv Code
                ":" {
                    Read-PsvCode
                }
                #PowerShell Code
                "{" {
                    Read-PsvPowerShell
                }
                
                default {
                    Stop-PsvParser -Message "Unvalid character '$PSItem'"
                }
            }
        }
        else {
            Read-PsvHtml
        }
    }
    Add-PsvTokenToTree
    Stop-PsvParser
    return $ParseTree

}