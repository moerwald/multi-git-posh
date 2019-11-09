
function GetFilteredRepositories{
    param($predicate = { $true})

        $path = Join-Path -Path $IndexDirectoryName -ChildPath $IndexFileName
        $gitRepoInfo = Get-Content $path | ConvertFrom-Json -Depth 10
        $gitRepoInfo.Repositories | Where-Object $predicate 
}