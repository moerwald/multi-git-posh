<#
.SYNOPSIS
    Formats the output of Get-GitStatusForAllGitRepositories in a colored table view.
.DESCRIPTION
    Formats the output of Get-GitStatusForAllGitRepositories in a colored table view. If there
    are not committed changes, or your local repositories are not in sync. with the remote
    ones the row will be colored yellow, otherwise green.
.EXAMPLE
    Get-GitStatusForAllRepositories | Format-GitStatusForAllRepositories

    Returns a colored table view of the status of the several GIT repositories in the index.
#>
function Format-GitStatusForAllRepositories {
    [CmdletBinding()]
    [Alias("Format-GitStatus", "fgs")]
    Param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $GitStatus
    )
    begin {
        Write-Host ""

        $maxRepoLength = -30
        $maxBranchLength = -35
        $maxStatusSummaryLength = -20
        $maxSynLength = -10
        $maxRemoteUrlLenght = -40

        $formatString = "{0,$maxRepoLength} {1, $maxBranchLength} {2, $maxStatusSummaryLength} {3, $maxSynLength} {4, $maxSynLength} {5,$maxRemoteUrlLenght}"
        $str = $formatString -f `
            "Repository" , `
            "Branch"         , `
            "StatusSummary" , `
            "Pushable"      , `
            "Pullable"     , `
            "RemoteUrl"   
                
        Write-Host $str -ForegroundColor Magenta

        $str = $formatString -f `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxRepoLength))) , `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxBranchLength))) , `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxStatusSummaryLength))) , `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxSynLength))) , `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxSynLength))) , `
            (New-Object -TypeName System.String -ArgumentList "-", ([System.Math]::Abs($maxRemoteUrlLenght))) 

        Write-Host $str -ForegroundColor Magenta
        Write-Host ""

    }

    process {
        
        $foreGroundColor = "Green"
        if (($_.WorkingTree.Added -gt 0) -or
            ($_.WorkingTree.Modified -gt 0) -or
            ($_.WorkingTree.Deleted -gt 0) -or
            ($_.Index.Added -gt 0) -or
            ($_.Index.Modified -gt 0) -or
            ($_.Index.Deleted -gt 0) 
        ) {
            $foreGroundColor = "Yellow"
        }

        if ($_.Pushable){
            $foreGroundColor = "DarkYellow"
        }

        $str = $formatString -f `
            (TruncateString $_.Repository     $maxRepoLength), `
            (TruncateString $_.Branch         $maxBranchLength ), `
            (TruncateString $_.StatusSummary  $maxStatusSummaryLength ), `
            (TruncateString $_.Pushable       $maxSynLength ), `
            (TruncateString $_.Pullable       $maxSynLength ), `
            (TruncateString $_.RemoteUrl      $maxRemoteUrlLenght )
                
        Write-Host $str -ForegroundColor $foreGroundColor

    }
    
    end {
        Write-Host ""
    }
}

function TruncateString {
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $string,
        [Parameter(Mandatory, Position = 1)]
        [int]
        $maxLength
    )

    $length = [System.Math]::Abs($maxLength)
    if ($string.Length -gt $length ) {
        $string = ($string.Substring(0, $length)) -replace "...$", "..."
    }

    $string
}