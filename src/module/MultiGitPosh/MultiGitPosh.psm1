$Private = @(Get-ChildItem "$PSScriptRoot/Private" -Recurse -Include *.ps1)
$Public  = @(Get-ChildItem "$PSScriptRoot/Public" -Recurse -Include *.ps1)

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
        Write-Verbose "Sourced $($import.fullname)"
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName