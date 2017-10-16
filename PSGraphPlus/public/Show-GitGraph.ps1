function Show-GitGraph
{
    <#
    .SYNOPSIS
    Gets a graph of the git history
    
    .DESCRIPTION
    This will generate a graph showing the recent histroy of a project with the branches.
    
    .PARAMETER Path
    Local location of the Git repository
    
    .PARAMETER HistoryDepth
    How far back into history to show
    
    .PARAMETER Uri
    Allows the injection of a base URL for github projects
    
    .PARAMETER ShowCommitMessage
    This will show the git commit instead of the hash
    
    .PARAMETER Raw
    Output the raw graph without generating the image or showing it. Useful for testing.
    
    .EXAMPLE
    Show-GitGraph    
    
    .EXAMPLE
    Show-GitGraph -HistoryDepth 30
    

    .EXAMPLE
    Show-GitGraph -Path c:\workspace\project -ShowCommitMessage

    .NOTES
    
    #>
    [CmdletBinding()]
    param(
        $Path = $PWD,
        [alias('Depth')]
        $HistoryDepth = 15,
        $Uri = 'https://github.com/KevinMarquette/PSGraph',
        [switch]
        $ShowCommitMessage,
        [switch]
        $Raw
    )
    process
    {
        Push-Location $Path
        # Git history with branch details
        $git = git log --format="%h|%p|%s" -n $HistoryDepth --branches=* | Select-Object -SkipLast 1
        $HASH = 0
        $PARENT = 1
        $SUBJECT = 2
        $branches = git branch -a -v

        if ($ShowCommitMessage)
        {
            $labelIndex = $SUBJECT
        }
        else 
        {
            $labelIndex = $HASH
        }
        
        $graph = graph git  @{ rankdir = 'LR'; label = [regex]::Escape( $PWD) } {
            Node @{shape = 'box'}
            foreach ($line in $git)
            {
                $data = $line.split('|')
                Node -Name $data[$HASH] @{
                    label = $data[$labelIndex]
                    URL   = "{0}/commit/{1}" -f $Uri, $data[$HASH]
                }
                Edge -From $data[$PARENT].split(' ') -To $data[$HASH]
            } 
            
            Node @{shape = 'box'; fillcolor = 'green'; style = 'filled'}
            foreach ($line in $branches)
            {
                if ($line -match '(?<branch>[\w/-]+)\s+(?<hash>\w+) (.+)')
                {
                    Node $Matches.branch 
                    Edge $Matches.branch -From $Matches.hash
                }
            }
        } 
        
        if ($Raw)
        {
            $graph
        }
        else
        {
            $graph | Export-PSGraph -ShowGraph
        }    

        Pop-Location
    }
}