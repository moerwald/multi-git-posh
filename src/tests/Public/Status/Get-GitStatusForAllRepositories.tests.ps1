Remove-Module MultiGitPosh -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../../../module/MultiGitPosh/MultiGitPosh.psd1" 

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
        Remove-Item "$env:TEMP/testRepos" -Recurse -Force
    }

    Context "Tests for GIT index" {

        It "New file was staged for commit" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."Index"."Added".Count | Should -Be 1
        }

        It "Committed file has changed" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
                git commit -m "Some commit message"

                # Change it after it was added
                "change" >> $file
                git add $file
            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."Index"."Modified".Count | Should -Be 1
        }

        It "Committed file was deleted via git rm" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
                git commit -m "Some commit message"

                # Change it after it was added
                git rm $file
            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."Index"."Deleted".Count | Should -Be 1
        }
    }

    Context "Tests for GIT working tree" {

        It "Committed file was deleted" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
                git commit -m "Some commit message"

                remove-item $file
            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."WorkingTree"."Deleted".Count | Should -Be 1
        }

        It "Committed file was changed but not added for commit" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
                git commit -m "Some commit message"

                "test" >> $file

            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."WorkingTree"."Modified".Count | Should -Be 1
        }


        It "File is untracked" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File
            }  -Predicate $predictate

            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."WorkingTree"."Added".Count | Should -Be 1
        }

        It "File was marked for commit AND changed afterwards" {
            $repoToCheck = "repo_1"
            $predictate = { $_.Name -eq $repoToCheck }

            # Arrange
            ForEach-GitRepository -Callback { 
                # Create the file
                $file = "newFile.txt"
                New-Item -Name $file -ItemType File

                # Add it to the GIT index
                git add $file
                git commit -m "Some commit message"

                # Chang the file after committing it
                "someText" >> $file

            }  -Predicate $predictate

            # Act
            $status = Get-GitStatusForAllRepositories -PassThrugh -Predicate $predictate

            # Assert
            $repoInfo = $status | Where-Object { $_.Repository -eq "repo_1"} 
            $repoInfo."WorkingTree"."Modified".Count | Should -Be 1
        }

    }

}