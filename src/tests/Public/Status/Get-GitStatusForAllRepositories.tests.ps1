Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh.psd1" -Verbose

. "$PSScriptRoot/../../Helpers/CreateTestRepositories.ps1"

Describe "Tests to check if git status functionallity works" {

    BeforeEach {
        CreateTestRepositories 
        Push-Location
        Set-Location "$env:TEMP/testRepos"
        New-GitRepositoryIndex 
    }

    AfterEach {
        Pop-Location
    }

    It "New file was created but not added to GIT index"{
        $repoToCheck = "repo_1"
        $predictate = { $_.Name -eq $repoToCheck}
        ForEach-GitRepository -Callback { New-Item -Name "newFile.txt" -ItemType File}  -Predicate $predictate

        $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
        $status."repo_1"."FilesNotAddedToIndex".Count | Should -Be 1
    }

    It "Already indexed file was changed"{
    }

    It "File was marked for commit"{
    }

    It "File was marked for commit AND changed afterwards"{
    }
}