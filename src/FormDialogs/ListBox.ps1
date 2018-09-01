using namespace System.Drawing
using namespace System.Windows.Forms

function Show-ListBox {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Items
    )
    
    $Form = New-Object Form
    $Form.Size = New-Object Size 325, 200
    $Form.MinimumSize = New-Object Size 325, 200
    $Form.StartPosition = "CenterScreen"
    $Form.Text = $Title
    $Form.Topmost = $true
    
    $Label = New-Object Label
    $Label.Location = New-Object Point 10, 20
    $Label.Size = New-Object Size 280, 20
    $Label.Text = "Please make a selection from the list below:"
    $Form.Controls.Add($Label)
    
    $ListBox = New-Object Listbox
    $ListBox.Anchor = [AnchorStyles] "Bottom, Left, Right, Top"
    $ListBox.Location = New-Object Point 10, 40
    $ListBox.Size = New-Object Size 289, 70
    $ListBox.SelectionMode = "MultiExtended"
    
    foreach ($Item in $Items) {
        $ListBox.Items.Add($Item) | Out-Null
    }
    $Form.Controls.Add($ListBox)
    
    $DeleteButton = New-Object Button
    $DeleteButton.Anchor = [AnchorStyles]::Bottom
    $DeleteButton.Location = New-Object Point 30, 120
    $DeleteButton.Size = New-Object Size 75, 23
    $DeleteButton.Text = "Delete"
    $DeleteButton.DialogResult = [DialogResult]::OK
    $Form.AcceptButton = $DeleteButton
    $Form.Controls.Add($DeleteButton)
    
    $SkipButton = New-Object Button
    $SkipButton.Anchor = [AnchorStyles]::Bottom
    $SkipButton.Location = New-Object Point 115, 120
    $SkipButton.Size = New-Object Size 75, 23
    $SkipButton.Text = "Skip"
    $SkipButton.DialogResult = [DialogResult]::Ignore
    $Form.Controls.Add($SkipButton)
    
    $AbortButton = New-Object Button
    $AbortButton.Anchor = [AnchorStyles]::Bottom
    $AbortButton.Location = New-Object Point 200, 120
    $AbortButton.Size = New-Object Size 75, 23
    $AbortButton.Text = "Abort"
    $AbortButton.DialogResult = [DialogResult]::Abort
    $Form.CancelButton = $AbortButton
    $Form.Controls.Add($AbortButton)
    
    $Result = $Form.ShowDialog()
    
    if ($Result -eq [DialogResult]::OK) {
        Write-Output $ListBox.SelectedItems
    } elseif ($Result -eq [DialogResult]::Ignore) {
        Write-Output (,@())
    }
}