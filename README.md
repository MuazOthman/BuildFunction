# BuildFunction
Build a single serverless function using SAM.

## Usage

In Powershell, navigate to the folder containing `template.yaml` then you can:
- Run `Build-Function <FunctionName>` if you know the function name; or
- Use interactive mode by simply running `Build-Function` and the tool will present you with a list of all functions in `template.yaml` to choose from.

## Installation

1. Clone this repo
2. Copy the subfolder `BuildFunction` (**not the whole repo**) into `C:\Users\<your-username>\Documents\WindowsPowerShell\Modules`
3. If you don't already have a file `C:\Users\<your-username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` then create it as an empty file
4. Run Powershell as administrator and execute: `Install-Module powershell-yaml` and verify.
5. Edit `C:\Users\<your-username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` and add a new line: `Import-Module BuildFunction`
6. Start a new Powershell console and verify that you can see this warning:
```
WARNING: The names of some imported commands from the module 'BuildFunction'
include unapproved verbs that might make them less discoverable.
To find the commands with unapproved verbs, run the Import-Module command again with the Verbose parameter.
For a list of approved verbs, type Get-Verb.
```
