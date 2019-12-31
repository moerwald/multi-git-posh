
Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh/MultiGitPosh.psd1" 

Describe "Tests to check if git status functionallity works" {

    $cloneDirectory = Join-Path $env:TEMP ([System.Guid]::NewGuid())
    $indexFilePath = Join-Path $cloneDirectory "./.index_multi_git_posh/index_git_repos.json"

    BeforeEach {
        Push-Location

        Clone-GitRepositories -GitIndexfile "$PSScriptRoot/index.json" -DirectoryToCloneTo $cloneDirectory
        Set-Location $cloneDirectory
    }

    AfterEach {
        Pop-Location
        Remove-Item -Path $cloneDirectory -Recurse -Force
    }

    Context "Clone repos from index file" {

        It "Number of cloned repos is correct" {
            function NRepositoriesExist {
                param($NrOfRepos)

                (Get-ChildItem -Exclude ".index_multi_git_posh").Count | Should -Be $NrOfRepos
            }

            NRepositoriesExist -NrOfRepos 2
        }

        It "Index file was copied to clone directory" {
            (Get-ChildItem $indexFilePath).Count | Should -Be 1
        }

        It "Path attribute was set in index file " {
            $gitRepoInfo = Get-Content -Path $indexFilePath | ConvertFrom-Json -Depth 10
            foreach( $repo in $gitRepoInfo.Repositories) {
                $repo.Path | Should -Not -BeNullOrEmpty
            }
        }
    }
}