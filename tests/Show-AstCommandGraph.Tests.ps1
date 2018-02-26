Describe 'function Show-AstCommandGraph' -Tag Build {
    it 'will parse a file' {
        $path = "$PSScriptRoot\..\output\psgraphplus\psgraphplus.psm1"
        $path | Should exist
        Show-AstCommandGraph -Path $path -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }

    it 'will process a scriptblock' {
        $script = {
            function test-function
            {
                Write-Output 'thing'
            }
        }

        $script | Show-AstCommandGraph -AllCommands -AllCalls -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }
}