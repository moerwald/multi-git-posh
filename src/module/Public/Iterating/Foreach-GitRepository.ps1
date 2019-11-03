<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function ForEach-GitRepository {
    [CmdletBinding(
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Low')]
    [Alias("fgr")]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $Callback, 
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $ChangeLocationToGitRepo = $true,
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $Predicate = { $true}
    )
    
    begin {
    }
    
    end {
        $path = Join-Path -Path $IndexDirectoryName -ChildPath $IndexFileName
        $gitRepoInfo = Get-Content $path | ConvertFrom-Json -Depth 10

        $gitRepoInfo.Repositories | Where-Object $Predicate | ForEach-Object -Process {
            if ($Callback){
                if ($ChangeLocationToGitRepo){
                    # Change to GIT repo directory
                    try{
                        Push-Location
                        Set-Location $_.Path
                        $Callback.InvokeWithContext(@{ }, @(New-Object "PSVariable" @("_", $_)))
                    }
                    finally{
                        Pop-Location
                    }
                }
                else {
                    # Invoke callback where we currently are
                    $Callback.InvokeWithContext(@{ }, @(New-Object "PSVariable" @("_", $_)))
                }
            }
        }
    }
}