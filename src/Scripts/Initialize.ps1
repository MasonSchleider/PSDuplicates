Push-Location $PSScriptRoot\..

$SourceFiles = @()
$SourceFiles += Get-ChildItem .\CustomControls\CustomControls *.cs | Resolve-Path -Relative
$SourceFiles += Get-ChildItem .\CustomControls\CustomControls -Exclude bin, obj, Properties -Directory | % {
    Get-ChildItem $_ *.cs -Recurse
} | Resolve-Path -Relative
$OutputPath = '.\lib\CustomControls.dll'

$ReferencedAssemblies = @(
    'System.Drawing',
    'System.Windows.Forms'
)

if (Test-Path $OutputPath) {
    $LibFile = Get-Item $OutputPath
    
    foreach ($SourcePath in $SourceFiles) {
        $SourceFile = Get-Item $SourcePath
        
        if ($SourceFile.LastWriteTime -gt $LibFile.LastWriteTime) {
            Add-Type -Path $SourceFiles -OutputAssembly $OutputPath -OutputType Library -ReferencedAssemblies $ReferencedAssemblies
            break
        }
    }
} else {
    Add-Type -Path $SourceFiles -OutputAssembly $OutputPath -OutputType Library -ReferencedAssemblies $ReferencedAssemblies
}

Pop-Location