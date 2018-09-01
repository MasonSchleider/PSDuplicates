using namespace System.Drawing
using namespace System.Windows.Forms

function Show-ListView {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [object[]]$Columns,
        
        [Parameter(Mandatory=$true)]
        [object[]]$Items
    )
    
    $Form = New-Object Form
    $Form.Size = New-Object Size 600, 400
    $Form.MinimumSize = New-Object Size 600, 400
    $Form.StartPosition = "CenterScreen"
    $Form.Text = $Title
    $Form.Topmost = $true
    
    $Label = New-Object Label
    $Label.Location = New-Object Point 10, 20
    $Label.Size = New-Object Size 280, 20
    $Label.Text = "Please make a selection from the list below:"
    $Form.Controls.Add($Label)
    
    $ListView = New-Object ListView
    $ListView.Anchor = [AnchorStyles] "Bottom, Left, Right, Top"
    $ListView.Location = New-Object Point 10, 40
    $ListView.Size = New-Object Size 564, 270
    $ListView.View = [View]::Details
    
    foreach ($Column in $Columns) {
        $ListView.Columns.Add(
            $(if ($Column.Name -ne $null) { $Column.Name } else { $Column }),
            $(if ($Column.Width -ne $null) { $Column.Width } else { -2 }),
            $(if ($Column.Alignment -ne $null) { [HorizontalAlignment]::($Column.Alignment) } else { [HorizontalAlignment]::Left })
        ) | Out-Null
    }
    
    foreach ($Item in $Items) {
        if ($Item -is [array]) {
            $Subitems = $Item
        } else {
            $Subitems = @()
            foreach ($Property in $Item.psobject.Properties) {
                if ($Property.Value -ne $null) {
                    $Subitems += $Property.Value.ToString()
                } else {
                    $Subitems += ""
                }
            }
        }
        
        $ListViewItem = New-Object ListViewItem $Subitems[0]
        $ListViewItem.Tag = $Item
        for ($i = 1; $i -lt $Subitems.Count; $i++) {
            $ListViewItem.Subitems.Add($Subitems[$i]) | Out-Null
        }
        $ListView.Items.Add($ListViewItem) | Out-Null
    }
    $Form.Controls.Add($ListView)
    
    $DeleteButton = New-Object Button
    $DeleteButton.Anchor = [AnchorStyles]::Bottom
    $DeleteButton.Location = New-Object Point 165, 320
    $DeleteButton.Size = New-Object Size 75, 23
    $DeleteButton.Text = "Delete"
    $DeleteButton.DialogResult = [DialogResult]::OK
    $Form.AcceptButton = $DeleteButton
    $Form.Controls.Add($DeleteButton)
    
    $SkipButton = New-Object Button
    $SkipButton.Anchor = [AnchorStyles]::Bottom
    $SkipButton.Location = New-Object Point 250, 320
    $SkipButton.Size = New-Object Size 75, 23
    $SkipButton.Text = "Skip"
    $SkipButton.DialogResult = [DialogResult]::Ignore
    $Form.Controls.Add($SkipButton)
    
    $AbortButton = New-Object Button
    $AbortButton.Anchor = [AnchorStyles]::Bottom
    $AbortButton.Location = New-Object Point 335, 320
    $AbortButton.Size = New-Object Size 75, 23
    $AbortButton.Text = "Abort"
    $AbortButton.DialogResult = [DialogResult]::Abort
    $Form.CancelButton = $AbortButton
    $Form.Controls.Add($AbortButton)
    
    $Result = $Form.ShowDialog()
    
    if ($Result -eq [DialogResult]::OK) {
        Write-Output ($ListView.SelectedItems | Select-Object -ExpandProperty Tag)
    } elseif ($Result -eq [DialogResult]::Ignore) {
        Write-Output (,@())
    }
}