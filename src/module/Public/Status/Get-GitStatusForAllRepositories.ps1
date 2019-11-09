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
function Get-GitStatusForAllRepositories{
    [CmdletBinding()]
    [Alias("Get-GitStatus")]
    Param (
        # Predicate to filter GIT repositories, that should be excluded
        [Parameter(Mandatory = $false, Position = 0)]
        [scriptblock]
        $Predicate = { $true},
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
            git fetch --all
            $status = git status -s
            $filesNotAddedToIndex =  @($status | ForEach-Object { 
                if ($_ -match "^\?\?\s(.*)") { 
                    $Matches[1]
                } 
            })

            @{
                $_.Name = @{
                    "Repository" = $_.Name
                    "FilesNotAddedToIndex" = $filesNotAddedToIndex
                    "Path" = $_.Path
                    "RemoteUrl" = $_.RemoteUrl
                }
            }

        } -Parallel:$Parallel -Predicate $Predicate


        if (!$PassThrugh){
            $result | Format-Table
        }
        else{
            $result
        }
    }
}