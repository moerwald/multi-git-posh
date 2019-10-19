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

    It "All three repositories shall be iterated through"{
        $repos = [System.Collections.ArrayList]( "repo_1", "repo_2", "repo_3")
        $script:ctnr = 0
        ForEach-GitRepository -Callback { 
            $script:ctnr++ 
            $repos.Remove($_.Name)
        }

        # Check if all repos were iterated
        $script:ctnr | Should -Be 3
        $repos.Count | Should -Be 0
    }

    It "Exclude repo_2 from iteration"{
        $repos = [System.Collections.ArrayList]( "repo_1", "repo_2", "repo_3")
        $script:ctnr = 0
        ForEach-GitRepository -Callback { 
            $script:ctnr++ 
            $repos.Remove($_.Name)
        } -Predicate { $_.Name -ne "repo_2"}

        # Check if all repos were iterated
        $script:ctnr | Should -Be 2
        $repos.Count | Should -Be 1
        "repo_2" | Should -BeIn $repos
    }
}