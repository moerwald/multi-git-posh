<#
.SYNOPSIS
    Iterates over all GIT repositories defined in the index file.
.DESCRIPTION
    Iterates over all GIT repositories defined in the index file.
    With the $Callback parameter you can define a script block that
    is called in directory of the actual iterated GIT repository.
    If some repositories should be filtered a custom predicate can
    be given via the $Predicate parameter.
.EXAMPLE
    > ForEach-GitRepository -Callback { Write-host $_ } -Predicate { $_.Name -eq "AutoCake" }
       @{Path=C:\Users\andre\source\repos\AutoCake; Name=AutoCake; RemoteUrl=https://github.com/moerwald/AutoCake.git ; DefaultBranch=develop}

       Print all available information of the "AutoCake" repository.
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
                Write-Progress -Activity "Fetching info" -PercentComplete ($i/$reposToIterate.Count*100)
                $item = $reposToIterate[$i]
                
                & $invokeCallback -cb $Callback -path $item.Path -gitRepositoryObject $item
            }
        }
    }
}

