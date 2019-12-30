
Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh/MultiGitPosh.psd1" 

. "$PSScriptRoot/../../Helpers/CreateTestRepositories.ps1"

Describe "Tests to check if git status functionallity works" {

    $repo1Path = "$env:TEMP/testRepos/repo_1"
    $repo1ClonedPath = "$env:TEMP/testRepos_Cloned/repo_1"

    BeforeEach {
        # Setup GIT repos
        CreateTestRepositories 
        Push-Location
        Set-Location "$env:TEMP/testRepos"
        New-GitRepositoryIndex 

        # Setup some branches in orig repo_1
        Set-Location $repo1Path
        git checkout -b branch1; git checkout master
        git checkout -b branch2; git checkout master

        # Create a clone from repo_1, clone includes branch1 and branch2
        New-Item "$env:TEMP/testRepos_Cloned" -ItemType Directory
        Set-Location "$env:TEMP/testRepos_Cloned"
        git clone $env:TEMP/testRepos/repo_1 
        Set-Location $repo1ClonedPath
        "branch1", "branch2", "master" | ForEach-Object { git checkout $_}

        Set-Location "$env:TEMP/testRepos_Cloned"
        New-GitRepositoryIndex 

        # Delete branch1, so it is stale in the cloned reo
        Set-Location $repo1Path
        git branch -d branch1
    }

    AfterEach {
        Pop-Location
        Remove-Item "$env:TEMP/testRepos" -Recurse -Force
    }

    Context "Tests for stale branch removing" {

        It "Remove stale branch 1" {
            Set-Location "$env:TEMP/testRepos_Cloned"
            Remove-StaleBranches -Auto

            Set-Location $repo1ClonedPath
            (git branch -a | ForEach-Object { $_.Trim()}) | Should -Not -Contain "branch1"
        }
    }
}