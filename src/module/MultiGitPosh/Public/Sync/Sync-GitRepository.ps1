<#
.SYNOPSIS
    Syncs all defined repositories.
.DESCRIPTION
    Performs fetch or pull operation on all defined GIT repositories.
.EXAMPLE
    Sync-GitRepository -Pull

    Pulls changes of the remote tracking branch to the actual checked out
    branch.
.EXAMPLE
    Sync-GitRepository 

    Fetches all remote branches to the local GIT repositories.
#>
function Sync-GitRepository {
    [CmdletBinding(PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias("sgr")]
    [OutputType([String])]
    Param (
        # Pulls changes of into actual GIT branch
        [Parameter()]
        [Switch]
        $Pull
    )
    
    end {
        ForEach-GitRepository -Callback {
            Write-Host "Sync $($_.Name)" -ForegroundColor Magenta
            if ($Pull){
                git pull --tags
            }
            else{
                git fetch --all --prune --tags
            }
        }
    }
}