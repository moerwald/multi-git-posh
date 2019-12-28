function Get-ActualGitBranch {
    [CmdletBinding()]
    param (
    )
    
    end {
       git rev-parse --abbrev-ref HEAD
    }
}