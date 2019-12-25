# Copied from https://raw.githubusercontent.com/RamblingCookieMonster/PSStackExchange/master/psake.ps1

# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = $PSScriptRoot
        }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }

    $ENV:BHPSModulePath = "./src/module/MultiGitPosh.psd1"
}

Task Default -Depends Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Build -Depends Init {
    $lines
    
    $relativePathToManifest = "src/module/MultiGitPosh.psd1"
    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions -Name $relativePathToManifest

    # Bump the module version
    Try
    {
        Step-ModuleVersion -Path $relativePathToManifest -By Minor
    }
    Catch
    {
        "Failed to update version for '$relativePathToManifest': $_.`nContinuing with existing version"
    }
}

Task Deploy -Depends Build {
    $lines
    "Publishing $($env:BHProjectName) from $($ENV:BHPSModulePath) to $($env:BHPSRepoName)"

    # Publish-Module -Repository MultiGitPosh  -Path $ENV:BHPSModulePath
}
