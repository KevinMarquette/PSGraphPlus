function Show-ServiceDependencyGraph
{
    <#
    .SYNOPSIS
    Show the process dependency graph

    .DESCRIPTION
    Loads all processes and maps out the dependencies

    .EXAMPLE
    Show-ServiceDependencyGraph

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        # Service Name
        [Parameter()]
        [string[]]
        $Name,

        # Remote computer name
        [Parameter()]
        [string[]]
        $ComputerName,

        # Credential for authorization
        [Parameter()]
        [pscredential]
        $Credential,

        # Outputs the raw dot graph (for testing)
        [switch]
        $Raw
    )

    process
    {
        if ( $null -ne $ComputerName )
        {
            Write-Verbose 'Connecting to remote system'
            $PSBoundParameters.Remove('Raw')
            $services = Invoke-Command @PSBoundParameters -ScriptBlock {Get-Service -Include *}
        }
        else
        {
            $services = Get-Service -Include *
        }

        if ($null -ne $Name)
        {
            Write-Verbose ( 'Filtering on name [{0}]' -f ( $Name -join ',' ) )
            $services = foreach ($node in $services)
            {
                if ($node.Name -in $Name)
                {
                    $node
                    continue
                }
                foreach ($dependency in $node.ServicesDependedOn.Name)
                {
                    if ( $dependency -in $Name)
                    {
                        $node
                        continue
                    }
                }
            }
        }

        if ( $null -eq $services ) { return }

        Set-NodeFormatScript {$_.tolower()}
        $graph = graph services  @{rankdir = 'LR'; pack = 'true'} {
            Node @{shape = 'box'}

            Node $services -NodeScript {$_.name} @{
                label = {'{0}\n{1}' -f $_.DisplayName, $_.Name}
                color = {If ($_.Status -eq 'Running') {'blue'}else {'red'}}
            }
            $linkedServices = $services | Where-Object {$_.ServicesDependedOn}
            Edge $linkedServices -FromScript {$_.Name} -ToScript {$_.ServicesDependedOn.Name}
        }
        Set-NodeFormatScript

        if ($Raw)
        {
            $graph
        }
        else
        {
            $graph | Export-PSGraph -ShowGraph
        }
    }
}
