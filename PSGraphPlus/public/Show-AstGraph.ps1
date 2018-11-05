function Show-AstGraph
{
    <#
    .Synopsis
    Creates a full AST diagram

    .Description
    Parses a script for all the AST elements and builds a graph out of them.

    .PARAMETER ScriptBlock
    a scriptblock to process

    .PARAMETER ScriptText
    The raw text of a script to process

    .PARAMETER Path
    The path to a script to process

    .PARAMETER Annotate
    Expand the graph and show AST object types

    .PARAMETER Raw
    Produces a raw dot file.

    .EXAMPLE
    $script = {
        function test-function () {
            Write-Output 'test'
        }

        function other-function () {
            test-function
        }
    }

    $script | Show-AstGraph

    .NOTES

    #>
    [cmdletbinding(DefaultParameterSetName = 'ScriptBlock')]
    param(
        [parameter(
            ParameterSetName = 'ScriptBlock',
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $ScriptBlock,

        [parameter(
            ParameterSetName = 'ScriptText'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ScriptText,

        [parameter(
            ParameterSetName = 'Path',
            ValueFromPipeline,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [switch]
        $Annotate,

        [switch]
        $Raw
    )

    process
    {
        if (![string]::IsNullOrWhiteSpace($Path))
        {
            $ScriptText = Get-Content $Path -Raw -ErrorAction Stop
        }
        if (![string]::IsNullOrWhiteSpace($ScriptText))
        {
            $ScriptBlock = [scriptblock]::Create($ScriptText)
        }

        $script:DebugAst = $Annotate
        $ast = $ScriptBlock.Ast
        $nodesAndEdges = Get-AstMap -Ast $ast

        $options = @{
            rankdir = 'LR'
            splines = 'true'
            nodesep = '0.6'
        }
        $graph = graph $options {
            node @{shape = 'box'}
            $nodesAndEdges
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
