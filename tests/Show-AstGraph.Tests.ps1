Describe 'Function Show-AstGraph' -Tag Build {

    Context 'Annotations' {
        BeforeEach {
            $script = {$VARIABLE_NAME}
        }

        It "Show-AstGraph -Annotate should annotate AST elements" {
            $graph = Show-AstGraph -ScriptBlock $Script -Raw -Annotate
            $graph | Out-String | Should -Match 'VARIABLE_NAME' -Because 'This is in the scriptblock'
            $graph | Out-String | Should -Match 'VariableExpressionAst'
            $graph | Out-String | Should -Match 'PipelineAst'
            $graph | Out-String | Should -Match 'CommandExpressionAst'
            $graph | Out-String | Should -Match 'NamedBlockAst'
            $graph | Out-String | Should -Match 'ScriptBlockAst'
        }

        It "Show-AstGraph should not annotate AST elements" {
            $graph = Show-AstGraph -ScriptBlock $Script -Raw
            $graph | Out-String | Should -Match 'VARIABLE_NAME' -Because 'This is in the scriptblock'
            $graph | Out-String | Should -Not -Match 'VariableExpressionAst'
            $graph | Out-String | Should -Not -Match 'PipelineAst'
            $graph | Out-String | Should -Not -Match 'CommandExpressionAst'
            $graph | Out-String | Should -Not -Match 'NamedBlockAst'
            $graph | Out-String | Should -Not -Match 'ScriptBlockAst'
        }
    }
}
