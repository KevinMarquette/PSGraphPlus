#invoke-build clean, default
#Show-AstCommandGraph -Path .\output\PSGraphPlus\PSGraphPlus.psm1 -AllCommands -AllCalls
Import-Module .\PSGraphPlus\PSGraphPlus.psd1 -Force
$script = {
    function test-function ()
    {
        Write-Output 'test'
    }
    function other-function ()
    {
        test-function
    }
}

$script | Show-AstGraph -Verbose
