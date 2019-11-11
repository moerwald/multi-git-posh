function Invoke-ExpressionAndThrowIfFailed {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [string]
        $command,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $callingFunctionName = "undef"
    )

    begin {
        $functionName = $MyInvocation.MyCommand
        Write-Verbose "[$functionName] Begin"

        # Check if the caller was called with -WhatIf -Confirm switches
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    end {
        if ($pscmdlet.ShouldProcess($command)) {
            $output = Invoke-Expression $command
            if ((-not $?) -or ($LASTEXITCODE -ne 0)) {
                throw "[$callingFunctionName]: invoke-expression failed for command $command. Command output: $output"
            }
            $output
        }

        Write-Verbose "[$functionName] End"
    }
}