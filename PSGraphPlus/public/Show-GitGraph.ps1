enum Direction
{
    BottomToTop
    TopToBottom
    RightToLeft
    LeftToRight
}

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

    .PARAMETER Direction
    This sets the direction of the chart.

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
        $Raw,
        [Direction]
        $Direction = [Direction]::LeftToRight
    )

    begin
    {
        $directionMap = @{
            [Direction]::TopToBottom = 'TB'
            [Direction]::BottomToTop = 'BT'
            [Direction]::LeftToRight = 'LR'
            [Direction]::RightToLeft = 'RL'
        }
    }
    process
    {
        Push-Location $Path
        # Git history with branch details
        $git = git log --format="%h|%p|%s" -n $HistoryDepth --branches=* | Select-Object -SkipLast 1
        $HASH = 0
        $PARENT = 1
        $SUBJECT = 2
        $branches = git branch -a -v
        $tagList = git show-ref --abbrev=7 --tags
        $current = git log -1 --pretty=format:"%h"

        $tagLookup = @{}
        foreach ($tag in $tagList)
        {
            $tagHash, $tagName = $tag -split ' '

            if (-not $tagLookup.ContainsKey($tagHash))
            {
                $tagLookup[$tagHash] = @()
            }
            $tagLookup[$tagHash] += $tagName.replace('refs/tags/', '')

        }

        $commits = @()
        $graph = graph git  @{ rankdir = $directionMap[$Direction]; label = [regex]::Escape( $PWD); pack = 'true' } {
            Node @{shape = 'box'}
            foreach ($line in $git)
            {
                $data = $line.split('|')
                $label = $data[$HASH]
                if ($ShowCommitMessage)
                {
                    $label = '{0}\n{1}' -f $data[$SUBJECT], $data[$HASH]
                    $commitID = 'commit' + $data[$HASH]
                    Node $commitID @{label = $data[$SUBJECT]; shape = 'plaintext'}

                    Rank $commitID, $data[$HASH]
                    Edge -From $commitID -To $data[$HASH] @{style = 'dotted'; arrowhead = 'none'}
                    $commits = @($commitID) + @($commits)
                }

                Node -Name $data[$HASH] @{
                    URL = "{0}/commit/{1}" -f $Uri, $data[$HASH]
                }
                Edge -From $data[$PARENT].split(' ') -To $data[$HASH]

                #add tags
                if ($tagLookup.ContainsKey($data[$HASH]))
                {
                    Node $tagLookup[$data[$HASH]] @{fillcolor = 'yellow'; style = 'filled'}
                    Edge -From $tagLookup[$data[$HASH]] -To $data[$HASH]
                }
            }
            if ($commits.Count)
            {
                Edge $commits @{style = 'invis'}
            }

            # branches
            Node @{shape = 'box'; fillcolor = 'green'; style = 'filled'}
            foreach ($line in $branches)
            {
                if ($line -match '(?<branch>[\w/-]+)\s+(?<hash>\w+) (.+)')
                {
                    Node $Matches.branch
                    Edge $Matches.branch -To $Matches.hash
                }
            }

            # current commit
            Node $current @{fillcolor = 'gray'; style = 'filled'}
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