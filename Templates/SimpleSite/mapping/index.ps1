<#
    This is the content of the VARIABLE: $PsvData
    Errors of type: Value not found '$PsvData.Customer.Name' should be checked here (in the controller file)
#>
@{

    <#
        Fill the data container with every single external PS script that you will be using
        The name of the object is the same name you must use on your View
        e.g.
        *.psv.html:
            <span>There ${if ($PsvData.Example.PidAmount -gt 1) {"are"} else {"is"}} $Example.PidAmount ${if ($PsvData.Example.PidAmount -gt 1) {"processes"} else {"process"}} for $Example.ProcessName</span>
        
        *.psv.ps1 (This file):
            Example = .$PSScriptRoot\..\model\SomePowerShellFile.ps1

        If the script has to run differently based on user input, pass the $args variable to the functions (the functions must support input parameters)
    #>

    About = .$PSScriptRoot\..\scripts\Get-PsvAbout.ps1 #-Parameter1 $args[0]

    Example = &{
        $proc = Get-Process | Group-Object -Property ProcessName | Sort-Object -Property Count -Descending | Select-Object -First 1

        return @{
            PassedByArg = $args[0] #this is the parameter entering into this lambda/anonymous function
            ProcessName = $proc.Name
            PidAmount = $proc.Count
        }
    } $args[0] #This is the $args[0] coming from Get-PsvPage, which obtained the arguments from Invoke-PsvReport.ps1 (This is the one you run)
}