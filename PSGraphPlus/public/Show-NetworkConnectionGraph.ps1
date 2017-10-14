function Show-NetworkConnectionGraph
{
    <#
    .SYNOPSIS
    Generates a map of network connections
    
    .Description
    This graph will show the source and target IP addresses with each edge showing the ports

    .EXAMPLE
    Show-NetworkConnectionGraph
    
    .Example
    Show-NetworkConnectionGraph -ComputerName $server -Credential $Credential

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
        $Credential
    )

    process
    {
        $session = @{}
        if ( $null -ne $ComputerName -and $Credential )
        {
            $session = @{
                CimSession = New-CimSession @PSBoundParameters
            }
        }
        elseif ( $CimSession )
        {
            $session = @{
                CimSession = $CimSession
            }
        }

        $netstat = Get-NetTCPConnection -State Established, TimeWait -ErrorAction SilentlyContinue @session
        $netstat = $netstat | Where-Object LocalAddress -NotMatch ':'
        $dns = Get-DnsClientCache @session | Where-Object data -in $netstat.RemoteAddress
        
        graph network @{rankdir = 'LR'; label = 'Network Connections'} {
            Node @{shape = 'rect'}

            $EdgeParam = @{
                Node       = $netstat
                FromScript = {$_.LocalAddress}
                ToScript   = {$_.RemoteAddress}
                Attributes = @{label = {'{0}:{1}' -f $_.LocalPort, $_.RemotePort}}
            }
            Edge @EdgeParam

            Node $dns -NodeScript {$_.data} @{label = {'{0}\n{1}' -f $_.entry, $_.data}}

        } | Export-PSGraph -ShowGraph
    }
}