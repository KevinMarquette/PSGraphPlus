function Show-ProcessConnectionGraph
{
    <#
    .SYNOPSIS
    Generates a map of network connections

    .Description
    This graph will show the source and target IP addresses with each edge showing the ports

    .EXAMPLE
    Show-ProcessConnectionGraph

    .Example
    Show-ProcessConnectionGraph -ComputerName $server -Credential $Credential

    .NOTES

    #>
    [CmdletBinding( DefaultParameterSetName = 'Default' )]
    param(
        # Remote computer name
        [Parameter( ParameterSetName = 'Default' )]
        [string[]]
        $ComputerName,

        # Credential for authorization
        [Parameter( ParameterSetName = 'Default' )]
        [pscredential]
        $Credential,

        # Outputs the raw dot graph (for testing)
        [switch]
        $Raw
    )

    process
    {
        $session = @{}
        if ( $null -ne $ComputerName )
        {
            $PSBoundParameters.Remove('Raw')
            $session = @{
                CimSession = New-CimSession @PSBoundParameters
            }
        }

        $netstat = Get-NetTCPConnection -State Established, TimeWait -ErrorAction SilentlyContinue @session
        $netstat = $netstat | Where-Object LocalAddress -NotMatch ':'
        $dns = Get-DnsClientCache @session | Where-Object data -in $netstat.RemoteAddress

        $process = Get-CIMInstance -ClassName CIM_Process @session | Where-Object ProcessId -in $netstat.OwningProcess

        $graph = graph network @{rankdir = 'LR'; label = 'Process Network Connections'} {
            Node @{shape = 'rect'}
            Node $process -NodeScript {$_.ProcessID} @{label = {'{0}\n{1}' -f $_.ProcessName, $_.ProcessID}}

            $EdgeParam = @{
                Node       = $netstat
                FromScript = {$_.OwningProcess}
                ToScript   = {$_.RemoteAddress}
                Attributes = @{label = {'{0}:{1}' -f $_.LocalPort, $_.RemotePort}}
            }
            Edge @EdgeParam

            Node $dns -NodeScript {$_.data} @{label = {'{0}\n{1}' -f $_.entry, $_.data}}
        }

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
