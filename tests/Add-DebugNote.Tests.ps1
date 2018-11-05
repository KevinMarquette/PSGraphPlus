InModuleScope -ModuleName PSGraphPlus -Tag Build {
    Describe 'Function Add-DebugNote' {
        AfterAll {
            $script:DebugAST = $false
        }
        It 'Should create a node and an edge in AST debug mode' {
            $script:DebugAST = $true
            $dot = Add-DebugNote -ID PARENT_ID -Message DEBUG_MESSAGE
            $dot | Should -HaveCount 2
            $dot[0] | Should -Match 'shape="plaintext' -Because 'The note should be a plaintext node'
            $dot[0] | Should -Match 'DEBUG_MESSAGE' -Because 'The node should have a label with the message'
            $dot[1] | Should -Match '->' -Because "the 2nd item should be an edge"
            $dot[1] | Should -Match 'PARENT_ID' -Because 'The edge should be to the Parent ID'
        }
    
        It 'Does nothing when not in AST debug mode' {
            $script:DebugAST = $false
            $dot = Add-DebugNote -ID PARENT_ID -Message DEBUG_MESSAGE
            $dot | Should -BeNullOrEmpty            
        }
        Context 'Annotations' {
            BeforeEach {
                $script = {$VARIABLE_NAME}
            }

            It "Show-AstGraph -Annotate should create debug annotations" {
                $graph = Show-AstGraph -ScriptBlock $Script -Raw -Annotate
                $graph | Out-String | Should -Match 'VARIABLE_NAME' -Because 'This is in the scriptblock'
                $graph | Out-String | Should -Match ';style="dotted"' -Because 'Only annotations use the dotted style'
                $graph | Out-String | Should -Match 'VariableExpressionAst' 
            }

            It "Show-AstGraph should not create debug annotations " {
                $graph = Show-AstGraph -ScriptBlock $Script -Raw 
                $graph | Out-String | Should -Match 'VARIABLE_NAME' -Because 'This is in the scriptblock'
                $graph | Out-String | Should -Not -Match ';style="dotted"' -Because 'Only annotations use the dotted style'
                $graph | Out-String | Should -Not -Match 'VariableExpressionAst' 
            }
        }
    }
    
}