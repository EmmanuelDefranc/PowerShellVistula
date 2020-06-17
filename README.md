# PowerShellVistula
Framework to put PowerShell Code into HTML using a pseudo-MVC design pattern

Requirements:
- PowerShell 5.1 (it has not been tested on lower versions)

How to Run it:
- Download the whole repo,
- Open a PowerShell session, either from the Console App, ISE or VSCode
- Open Invoke-PsvReport.ps1.ps1 from the root folder and run it
- On the root folder you will have a new file: index.html (it will overwrite the one that already exists)
- You have just created the main demo of the framework

More demos/examples to be added

Next Steps:
- Join this framework with PowerShell Polaris: https://github.com/powershell/polaris
  and create powerful HTML websites with rendered PowerShell code


A quick overview of the folders/files in this framework:
Folder: bin
Files:
    ConvertTo-PsvTable.ps1
  Similar to 'ConvertTo-Html -Fragment' but re-created to fulfil with the specifics of this framework
  
    Get-PsvPage.ps1
  This script matches the 'view', 'controller' and the 'model' into a fully functional HTML file
  
    Invoke-PsvParser.ps1
  Use this file to parse your create psvhtml files - the parser divides the HTML code from PowerShell code
  
    Register-PsvIcon.ps1
  This script is loaded automatically when Get-PsvPage is called - it contains a list of emojis that you can use on your website

Folder: Controller
Files:
    *.psv.ps1
  Here will reside all your controller files i.e. the files that match the 'model' with the 'view' files

Folder: html
Files:
    *.psv.html
  Here you will put all your HTML (with embedded PS code) files that will be later used by the parser in order for it to tokenize the file

Folder: model
Files:
    *.ps1
  Here goes all youre PS1 code used for obtaining and manipulating the data before it is send to the controller and then mapped to the view
  Each script always has to return data so it is mapped, the data can be any object (psobject, pscutomobject, array, hashtable)

Folder: view
Files:
    *.psv.xml
  Here all the tokenized *.psv.html files (from the folder 'html') you parsed using Invoke-PsvParser from the folder 'bin' will land here
  These files are the result of the parsing and saved using the Export-CliXml
  Note: YOU SHOULD NOT EDIT THOSE FILES - whenever you change something on a *.psv.html file, just parse it again, avoid editing the xmls

Folder: root
Files:
    Invoke-PsvParser.ps1
  This is one of the two main scripts, used for parsing the *.psv.html from the 'html' folder into tokens in the 'view' folder (as XMLs)

    Invoke-PsvReport.ps1
  This is the script you want to use to get your final rendered HTML file with the PS Code already executed.
  If you plan using PowerShell Polaris,  remove the '| Out-File...', instead of that send it as the 'response' on Polaris so it appears
  as a rendered site on your website
  
    LICENSE
  Just the license file (MIT License)

    index.html
  Part of the basic demo, this is the ouput file if you opt on using the '| Out-File...' in the 'Invoke-PsvReport.ps1' on the root folder
