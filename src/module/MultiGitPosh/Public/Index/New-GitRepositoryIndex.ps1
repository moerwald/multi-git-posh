<#
.SYNOPSIS
    Builds up an index file containing information GIT information.
.DESCRIPTION
    Builds up an index file containing information GIT information. The cmd
    scans every subdirectory for a containing .git folder, fetches infos 
    and adds it to the index file. The index files is used for later
    multi repository operations (e.g. checking out a specifc branch for several
    GIT repos).
.EXAMPLE
   New-GitRepositoryIndex -RootPathOfGitRepositories "C:\temp\folderContainingMultipleGitRepos"
   Creates an index in the given directory under .index_multi_git_posh.
#>
function New-GitRepositoryIndex {
    [CmdletBinding(SupportsShouldProcess = $true,
        PositionalBinding = $true,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Low')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory = $false,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript ( { Test-Path -Path $_ })]
        $RootPathOfGitRepositories = (Get-Location)
    )
    
    begin {
    }
    
    end {
        $indexDirectoryName = ".index_multi_git_posh"
        $gitIndexFilePath = Join-Path -Path $RootPathOfGitRepositories -ChildPath $indexDirectoryName
        if (Test-Path -Path $gitIndexFilePath) {
            throw "$indexDirectoryName already exists under $RootPathOfGitRepositories. Use 'Update-GitRepositoryIndex' to add new GIT repositories"
        }

        # Scan for GIT repositories
        $foundGitRepositories = Get-ChildItem -Path . -Recurse -Depth 2 -Include ".git" -Hidden
        if ($foundGitRepositories.Count -eq 0){
            Write-Warning "No GIT repositories found under $RootPathOfGitRepositories"
            return
        }

        # Create folder for index file
        New-Item -Path $RootPathOfGitRepositories -Name $indexDirectoryName -ItemType Directory -ErrorAction SilentlyContinue

        $index = @{}
        $index.Repositories = @($foundGitRepositories.Parent.FullName | ForEach-Object `
            -Begin { Push-Location }  `
            -Process {
                Set-Location $_
                # Return GIT info that shall be stored in the index file
                @{
                    Path          = (Get-Location).Path
                    RemoteUrl     = git remote -v | Select-String "(?<remote>http(s)?://.*\s)" | Select-Object -first 1 @{Label = "remote"; Expression = { $_.Matches.Captures.Value } } | select-object -ExpandProperty remote
                    DefaultBranch = (git branch -a ) | ForEach-Object { $_ -match "(?<branch>^\*\s.*)" } | Where-Object { $_ } | ForEach-Object { $Matches.branch.Trim('*').Trim()} | Select-Object -First 1
                    Name = Split-Path -Path (git rev-parse --show-toplevel) -Leaf
                }
            } `
            -End { Pop-Location } 
        )

        # Create the index file
        $index | ConvertTo-Json | Out-File -LiteralPath (Join-Path -Path $gitIndexFilePath -ChildPath $IndexFileName)
    }
}