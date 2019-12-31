<#
.SYNOPSIS
    Returns a object containing the status of all GIT repositories noted in the index.
.DESCRIPTION
    Returns a object containing the status of all GIT repositories noted in the index.
    The returned object contains information about:
       - if your local repositories need to be synced.
       - number of files deleted, added, modified on the GIT index/workspace
       - local path of the repositories
       - remote URLs of the repositories
.EXAMPLE
    > Get-GitStatusForAllRepositories

    Repository                               Branch                                StatusSummary    Pushable Pullable RemoteUrl
    ----------                               ------                                -------------    -------- -------- ---------
    AutoCake                                 develop                               +0 ~0 -0 | ~0 -0 False    False    https://github.com/moerwald/AutoCake.git
    Cake.GetNuGetLicense                     develop                               +0 ~0 -0 | ~1 -0 False    False    https://github.com/moerwald/Cake.GetNuGetLicense.git     Cake.GitFlow                             feature/createAndMergeReleaseBranches +0 ~0 -0 | ~0 -0 False    False    https://github.com/moerwald/Cake.GitFlow.git
    c-sharp-git-hooks                        develop                               +0 ~0 -0 | ~2 -0 False    False    https://github.com/moerwald/c-sharp-git-hooks.git        dotnet-thirdpartynotices                 master                                +0 ~0 -0 | ~0 -0 False    False    https://github.com/wrathofodin/dotnet-thirdpartynotices… gitflow_playground                       master                                +0 ~0 -0 | ~0 -0 False    False    https://github.com/moerwald/gitflow_playground.git       github-pages-with-jekyll                 moerwald-patch-3                      +0 ~0 -0 | ~1 -0 False    False    https://github.com/moerwald/github-pages-with-jekyll.gi… hacker                                   master                                +0 ~0 -0 | ~1 -0 False    False    https://github.com/pages-themes/hacker.git

#>
function Get-GitStatusForAllRepositories {
    [CmdletBinding()]
    [Alias("Get-GitStatus")]
    Param (
        # Predicate to filter GIT repositories, that should be excluded
        [Parameter(Mandatory = $false, Position = 0)]
        [scriptblock]
        $Predicate = { $true },
        [Parameter(Mandatory = $false, Position = 1)]
        [switch]
        $PassThrugh,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]
        $Parallel
    )
    
    end {
        $result = ForEach-GitRepository -Callback {

            # Fetch remote repository info
            $null = git fetch --all

            # Check for file changes in local working tree, index
            $status = git status -s
            $added = "Added"
            $modified = "Modified"
            $deleted = "Deleted"

            $gitIndex = @{
                $added    = @()
                $modified = @()
                $deleted  = @()
            }

            $gitWorkTree = @{
                $added    = @()
                $modified = @()
                $deleted  = @()
            }

            # Detect files changes
            $status | ForEach-Object { 
                if ($_ -match "^A.?\s(.*)") {
                    $gitIndex.Added += $Matches[1]
                }
                if ($_ -match "^M.?\s(.*)") {
                    $gitIndex.Modified += $Matches[1]
                }
                if ($_ -match "^D.?\s(.*)") {
                    $gitIndex.Deleted += $Matches[1]
                }

                if ($_ -match "^\?\?\s(.*)") {
                    $gitWorkTree.Added += $Matches[1]
                }

                if ($_ -match "^.?M\s(.*)") {
                    $gitWorkTree.Modified += $Matches[1]
                }
                
                if ($_ -match "^.?D\s(.*)") {
                    $gitWorkTree.Deleted += $Matches[1]
                }
            }

            $statusSummary = "+{0} ~{1} -{2} | ~{3} -{4}" -f `
                $gitIndex.Added.Count, 
                $gitIndex.Modified.Count, 
                $gitIndex.Deleted.Count, 
                $gitWorkTree.Modified.Count, 
                $gitWorkTree.Deleted.Count 

            # Add behind, ahead, diverged info
            $pushable , $pullable = GetSyncStatus

            # Return the result to pipeline
            $gitStatus = [pscustomobject] @{
                "Repository"     = $_.Name
                "Branch"         = (Get-ActualGitBranch)
                "StatusSummary"  = $statusSummary
                "Pushable"       = $pushable
                "Pullable"       = $pullable
                "Index"          = $gitIndex
                "WorkingTree"    = $gitWorkTree
                "Path"           = $_.Path
                "RemoteUrl"      = $_.RemoteUrl
            }

            $gitStatus.PSObject.TypeNames.Insert(0,'Moerwald.GitStatus')
            $gitStatus

        } -Parallel:$Parallel -Predicate $Predicate

        # Return result to pipeline 
        $result
    }
}

function GetSyncStatus{
            $status = git status -uno
            $pushable = $pullable = $false
            if ($status -contains "ahead"){
                $pushable = $true
            } 
            elseif ($status -contains "behind") {
                $pullable = $true
                
            }
            elseif ($status -contains "diverged") {
                $pushable = $pullable = $true
            }

            $pushable, $pullable
}