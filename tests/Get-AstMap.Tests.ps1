InModuleScope -ModuleName PSGraphPlus {
    Describe 'Function Get-AstMap' -Tag Build {
        It 'Should not throw on null AST' {
            Get-AstMap -Ast $null
        }

        $testCases = @(
            @{
                Script   = {$a}
                Expected = '$a'
            }
            @{
                Script   = {'TEST_STRING'}
                Expected = "'TEST_STRING'"
            }
            @{
                Script   = {Test-Connection -ComputerName localhost}
                Expected = "Test-Connection", "-ComputerName", "LocalHost"
            }
        )

        It "Script <Script> AST should contain <Expected>" -TestCases $testCases {
            param($Script, $Expected)
            $results = Get-ASTMap -Ast $Script.Ast
            foreach ($test in $Expected)
            {
                $results | Out-String | Should -Match ([regex]::Escape($test))
            }
        }
    }
}