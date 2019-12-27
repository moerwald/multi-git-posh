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
    
    begin {
    }
    
    end {
        $result = ForEach-GitRepository -Callback {
            $null = git fetch --all
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

            @{
                $_.Name = @{
                    "Repository"     = $_.Name
                    "StatusSummary"  = $statusSummary
                    "Index"          = $gitIndex
                    "WorkingTree"    = $gitWorkTree
                    "Path"           = $_.Path
                    "RemoteUrl"      = $_.RemoteUrl
                }
            }

        } -Parallel:$Parallel -Predicate $Predicate


        if (!$PassThrugh) {
            $result | Select-Object Repository, StatusSummary, Path, RemoteUrl | Format-Table
        }
        else {
            $result
        }
    }
}