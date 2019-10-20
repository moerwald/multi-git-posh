function CreateTestRepositories {
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    Param (
    )
    
    end {

        Push-Location
        try {
            # Remove old test repositories
            Get-ChildItem $env:TEMP -Recurse -Include "testRepos*" | Remove-Item -Recurse -Force

            # Go to temp folder
            Set-Location $env:temp

            New-Item -Name "testRepos" -ItemType Directory -Path .
            Set-Location "testRepos"

            "repo_1", "repo_2", "repo_3" | Foreach-Object { 
                Push-Location
                try {
                    New-Item -Path . -ItemType Directory -Name $_
                    Set-Location $_
                    git init
                    "test" >> ReadMe.md
                    git add ReadMe.md
                    git commit -m "Initial commit"
                }
                finally {
                    Pop-Location
                }
            }
        }
        finally {
            Pop-Location
        }
    }
}