function New-Project {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateScript({
            if ([string]::IsNullOrEmpty($_)) {
                return Get-Location
            }
            if (-not ($_ | Test-Path)) {
                throw "The folder does not exist"
            }
            if ($_ | Test-Path -PathType Leaf) {
                throw "The Path argument cannot be a file. Only folder paths are allowed."
            }
            return $true
        })]
        [string]
        $Path,

        [ValidateSet("SimpleSite")]
        $Template
    )

    if (-not $Path) {
        $Path = Get-Location
    }

    try {
        Copy-Item -Path "$PSScriptRoot\..\Templates\$Template\*" -Destination $Path -Recurse -ErrorAction Stop
    }
    catch {
        throw "Unable to create a new project (copy): $PSItem"
    }

}