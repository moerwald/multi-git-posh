<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    General notes
.COMPONENT
    The component this cmdlet belongs to
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function Clone-GitRepositories {
    [CmdletBinding(SupportsShouldProcess = $true,
        PositionalBinding = $true,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    [Alias("cgr")]
    Param (
        # Path to GIT index file
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $GitIndexfile,
        
        # Directory to clone GIT repositores to
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DirectoryToCloneTo
    )
    
    end {
        try {
            Push-Location

            $gitIndexFilePath = CreateDirectoryStructure -DirectoryToCloneTo $DirectoryToCloneTo
            $pathToIndexFile = Join-Path $gitIndexFilePath $IndexFileName

            Copy-Item $GitIndexfile $pathToIndexFile 
            $pathToIndexFile = Resolve-Path $pathToIndexFile

            $gitRepoInfo = Get-Content $pathToIndexFile | ConvertFrom-Json -Depth 10

            Set-Location $DirectoryToCloneTo

            foreach ($repo in $gitRepoInfo.Repositories) {

                $remoteUrl = $repo.RemoteUrl
                Clone -RemoteUrl $remoteUrl

                $localGitRepo = ((Split-Path $remoteUrl -Leaf).Trim()) -replace "\.git$"
                Push-Location
                Set-Location $localGitRepo
                $repo | Add-Member -Name "Path" -MemberType NoteProperty -Value (Get-Location)

                Checkout -Branch $repo.DefaultBranch

                Pop-Location
            }

            UpdateIndexFile -GitRepoInfo $gitRepoInfo -PathToIndexFile $pathToIndexFile
        }
        finally {
            Pop-Location
        }
    }
}

function CreateDirectoryStructure {
    param ( $DirectoryToCloneTo)

    NewDirectoryIfNeeded  -DirectoryToCloneTo $DirectoryToCloneTo
    NewIndexFileDirectory -DirectoryToCloneTo $DirectoryToCloneTo
}

function NewDirectoryIfNeeded { 
    param ( $DirectoryToCloneTo)

    if (-Not (Test-Path $DirectoryToCloneTo -ErrorAction SilentlyContinue)) {
        New-Item $DirectoryToCloneTo -ItemType Directory | Out-Null
    }
}

function NewIndexFileDirectory {
    param ( $DirectoryToCloneTo)

    $gitIndexFilePath = Join-Path -Path $DirectoryToCloneTo -ChildPath $IndexDirectoryName
    if (Test-Path -Path $gitIndexFilePath) {
        throw "$indexDirectoryName already exists under $DirectoryToCloneTo. "
    }

    New-Item $gitIndexFilePath -ItemType Directory | Out-Null

    $gitIndexFilePath
}

function UpdateIndexFile {
    param($GitRepoInfo, $PathToIndexFile)

    $GitRepoInfo | ConvertTo-Json | Out-File $PathToIndexFile
}

function Clone {
    param($RemoteUrl)

    Write-Host "Cloning $RemoteUrl" -ForegroundColor Magenta
    Invoke-ExpressionAndThrowIfFailed -Command "git clone $RemoteUrl"
}

function Checkout {
    param($Branch)

    Write-Host "Checking out $Branch" -ForegroundColor Magenta
    Invoke-ExpressionAndThrowIfFailed -Command "git checkout $Branch"
}