$actGitBranch = git rev-parse --abbrev-ref HEAD
$filesToBePushed = git diff --stat --cached "origin/$actGitBranch"

if ($filesToBePushed | Where-Object { $_ -match ".*.ps1"}){
    # Call build script and check result code
    Push-Location
    Set-Location "$PScriptRoot/../src/tests"
    if (Invoke-Pester -PassThru | Where-Object { $_.TestResult.Passed -eq $false}){
        throw "Pester tests failed, won't push code to remote"
    }
}