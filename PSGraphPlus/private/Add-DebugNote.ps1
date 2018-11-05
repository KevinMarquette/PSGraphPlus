function Add-DebugNote
{
    param($Id, $Message)
    if ($script:DebugAST)
    {
        $debugID = New-Guid
        node -Name $debugID @{label = $Message; shape = 'plaintext'}
        edge -From $debugID -To $Id @{style = 'dotted'; arrowhead = 'none'}
    }
}