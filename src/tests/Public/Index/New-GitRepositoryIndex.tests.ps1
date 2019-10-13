Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh.psd1" -Verbose

Describe "test" {

    BeforeEach {
        Get-ChildItem $env:TEMP -Recurse -Include "testRepos*" | Remove-Item -Recurse -Force
        Push-Location
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
            finally{
                Pop-Location
            }
        }
    }

    AfterEach {
        Pop-Location
    }
    Context "test" {
        It "test" {
            New-GitRepositoryIndex 

            Test-Path ".index_multi_git_posh/index.json" | Should -BeTrue

        }
    }
}