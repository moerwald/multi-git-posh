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
        ConfirmImpact = 'Low')]
    [Alias("fgr")]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $Callback, 
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $Predicate = { $true },
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]
        $Parallel
    )
    
    begin {
    }
    
    end {
        $reposToIterate = GetFilteredRepositories -predicate $Predicate

        $invokeCallback = {
            param($cb, $path, $gitRepositoryObject)
            if ($cb) {
                # Change to GIT repo directory
                try {
                    Push-Location
                    Set-Location $path
                    $cb.InvokeWithContext(@{ }, @(New-Object "PSVariable" @("_", $gitRepositoryObject)))
                }
                finally {
                    Pop-Location
                }
            }
        }
        
        if ($Parallel) {
            $jobs = $reposToIterate | ForEach-Object -Process { 
                Start-Job { 
                    param($cmd, $cb, $path) 
                    # Script block parameters are projected as strings, therefore we've to recreate the scriptblock objects
                    & ([Scriptblock]::Create($cmd)) -cb ([Scriptblock]::Create($cb)) `
                        -path $path
                } -ArgumentList $invokeCallback, $Callback, $_.Path, $_
            }

            # Wait for the jobs and receive theirs results
            $null = Wait-Job -Job $jobs
            Receive-Job -Job $jobs
            $null = Remove-Job -Job $jobs
        }
        else {
            # Do actions sequential
            for ($i = 0; $i -lt $reposToIterate.Count; $i++) {
                $item = $reposToIterate[$i]
                
                & $invokeCallback -cb $Callback -path $item.Path -gitRepositoryObject $item
            }
        }
    }
}

