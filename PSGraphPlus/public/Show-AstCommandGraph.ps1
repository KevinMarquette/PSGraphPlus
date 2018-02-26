
Function Show-AstCommandGraph
{
    <#
    .SYNOPSIS
    Generates a graph of the commands called in a script

    .DESCRIPTION
    Generates a graph of the commands called in a script

    .PARAMETER ScriptBlock
    a scriptblock to process

    .PARAMETER ScriptText
    The raw text of a script to process

    .PARAMETER Path
    The path to a script to process

    .PARAMETER AllCommands
    Show commands called that are not part of the script or module

    .PARAMETER AllCalls
    Will show a line for each time a function is called

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

    $script | Show-AstCommandGraph

    .NOTES
    The core powershell cmdlets are filtered out of the graph.
    commands like foreach-object, write-verbose, ect just add noise

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
        $AllCommands,

        [switch]
        $AllCalls,

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

        $functions = $ScriptBlock.Ast | Select-AST -Type FunctionDefinitionAst
        $names = $functions.Name
        $commands = $names

        if ($AllCommands)
        {
            $commands = (Get-Command | Where-Object source -notlike Microsoft.PowerShell.* | Select-Object -ExpandProperty Name) + $names
            $commands = $commands | Select-Object -Unique
        }

        if ($null -ne $names)
        {

            $graph = Graph {
                node @{shape = 'box'}
                node $names

                foreach ($function in $functions)
                {
                    $calls = $function.Body | Select-Ast -Type CommandAst
                    $uniquecalls = $calls.commandelements |
                        Where-Object StringConstantType -eq 'BareWord' |
                        Select-Object -ExpandProperty Value -Unique:(-Not $AllCalls) |
                        ForEach-Object {$commands -eq $_ }

                    if ($uniquecalls)
                    {
                        edge $function.Name -To $uniquecalls
                    }
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
    }
}
