InModuleScope -ModuleName PSGraphPlus {
    Describe 'Function Get-AstRule' -Tag Build {
        It 'Return a known rule' {
            $rule = Get-AstRule -Name AssignmentStatementAst
            $rule | Should -Not -BeNullOrEmpty
            $rule.Visible | Should -Not -BeNullOrEmpty
            $rule.Label | Should -Not -BeNullOrEmpty
            $rule.ChildProperty | Should -Not -BeNullOrEmpty
        }

        It 'Return $null for unknown rule' {
            $rule = Get-AstRule -Name MissingRule
            $rule | Should -BeNullOrEmpty
        }
    }
}