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

        $foundGitRepositories = Get-ChildItem -Path . -Recurse -Depth 2 -Include ".git" -Hidden
        <#
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
        }
        #>

        New-Item -Path $RootPathOfGitRepositories -Name $indexDirectoryName -ItemType Directory -ErrorAction SilentlyContinue

        $index = $foundGitRepositories.Parent.FullName | ForEach-Object `
            -Begin { Push-Location }  `
            -Process {
                Set-Location $_
                @{
                    Path          = (Get-Location).Path
                    RemoteUrl     = git remote -v | Select-String "(?<remote>http(s)?://.*\s)" | Select-Object -first 1 @{Label = "remote"; Expression = { $_.Matches.Captures.Value } } | select-object -ExpandProperty remote
                    DefaultBranch = (git branch -a ) | ForEach-Object { $_ -match "(?<branch>^\*\s.*)" } | Where-Object { $_ } | ForEach-Object { $Matches.branch.Trim('*').Trim()} | Select-Object -First 1
                }
            } `
            -End { Pop-Location } 

        $index | ConvertTo-Json | Out-File -LiteralPath (Join-Path -Path $gitIndexFilePath -ChildPath "index.json")
    }
}