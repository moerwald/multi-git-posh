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
function Remove-StaleBranches {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([String])]
    Param (
        # If set all found branches are going to be deleted
        [Parameter()]
        [switch]
        $Auto
    )
    
    begin {
    }
    
    end {
        ForEach-GitRepository -Callback {
            Invoke-ExpressionAndThrowIfFailed -command "git fetch --all --prune"

            $localBranchesWithoutRemoteBranch = @(  
                $matches = git branch -vv | Select-string -Pattern "\[origin/(?<branchName>.*):\sgone" -AllMatches  
                $matches.Matches.Groups | Where-Object { 
                    $_.GetType().ToString() -eq "System.Text.RegularExpressions.Group" -and $_.Name -eq "branchName" 
                } | Select-Object -ExpandProperty value
            )

            if ($localBranchesWithoutRemoteBranch.Count -gt 0) {
                Write-Host "[$($_.Name)] Found stale branches" -ForegroundColor Magenta
                $localBranchesWithoutRemoteBranch | ForEach-Object {

                    # Todo: Move to private menu function in case we need below code in another function
                    $yes = "y"
                    $allowedAnswers = $yes, "n"
                    $answer = $yes
                    if (!$Auto) {
                        do {
                            $answer = (Read-Host -Prompt "Shall delete $_ ? ($($allowedAnswers -join "/"))").ToLower()
                        } until ($allowedAnswers -contains $answer)
                    }

                    if ($answer -eq $yes) {
                        Write-Host "`t Deleting branch $_" -ForegroundColor Magenta
                        # Delete the found branch
                        Invoke-ExpressionAndThrowIfFailed -command "git branch -D $_"
                    }
                }
            }
        }
    }
}