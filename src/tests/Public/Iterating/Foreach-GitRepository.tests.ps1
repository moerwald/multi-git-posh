Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh.psd1" -Verbose

. "$PSScriptRoot/../../Helpers/CreateTestRepositories.ps1"

Describe "Tests to check if repository iterating works" {

    BeforeEach {
        CreateTestRepositories 
        Set-Location "$env:TEMP/testRepos"

        New-GitRepositoryIndex 
    }

    AfterEach {
        Pop-Location
    }

    It "Index file contains three GIT repos" {

    }
}