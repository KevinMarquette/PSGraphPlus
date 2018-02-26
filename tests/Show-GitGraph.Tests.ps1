Describe 'function Show-GitGraph' -Tag Build {
    it 'will show a graph' {
        Show-GitGraph -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }

    it 'Depth parameter' {
        Show-GitGraph -depth 9 -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }

    it 'ShowCommitMessage parameter' {
        Show-GitGraph -ShowCommitMessage -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }

    it 'Direction parameter' {
        Show-GitGraph -Direction TopToBottom -Raw |
            Should -Not -BeNullOrEmpty -Because 'It should generate a raw DOT graph'
    }
}
