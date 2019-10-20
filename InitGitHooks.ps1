$gitHooksDirectory = "$PSScriptRoot/.githooks"

Write-Host "Telling GIT to use hooks from $gitHooksDirectory " -ForegroundColor Magenta

git config core.hooksPath $gitHooksDirectory