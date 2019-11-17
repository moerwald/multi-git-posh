Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
<<<<<<< HEAD
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh/MultiGitPosh.psd1" -Verbose
=======
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh.psd1" 
>>>>>>> - Removed verbose switch on Import-Module.

. "$PSScriptRoot/../../Helpers/CreateTestRepositories.ps1"

Describe "Tests for index file descripton" {

    BeforeEach {
        CreateTestRepositories 
        Push-Location
        Set-Location "$env:TEMP/testRepos"
    }

    AfterEach {
        Pop-Location
    }


    It "Index file is created" {
        New-GitRepositoryIndex 

        Test-Path "./.index_multi_git_posh/index_git_repos.json" | Should -BeTrue
    }

    It "Index file contains three GIT repos" {
        New-GitRepositoryIndex 

        $index = Get-Content "./.index_multi_git_posh/index_git_repos.json" | ConvertFrom-Json
        $index.Repositories.Count | Should -Be 3

    }
}