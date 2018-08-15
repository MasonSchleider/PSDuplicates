using namespace System.Drawing
using namespace System.Windows.Forms

function Show-ConfirmDialog {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [string]$Title = "Confirmation Dialog",
        
        [ValidateNotNullOrEmpty()]
        [string]$Message = "Are you sure you want to perform this action?"
    )
    
    $WorkingArea = [Screen]::PrimaryScreen.WorkingArea
    
    $Form = New-Object Form
    $Form.Size = New-Object Size 300, 140
    $Form.MaximumSize = New-Object Size ($WorkingArea.Width * 0.5), ($WorkingArea.Height * 0.8)
    $Form.MinimumSize = New-Object Size 300, 140
    $Form.AutoSize = $true
    $Form.StartPosition = "CenterScreen"
    $Form.Text = $Title
    $Form.Topmost = $true
    
    $MainPanel = New-Object TableLayoutPanel
    $MainPanel.AutoSize = $true
    $MainPanel.Dock = [DockStyle]::Fill
    $MainPanel.Padding = 10
    $MainPanel.RowCount = 2
    $MainPanel.ColumnCount = 1
    $MainPanel.RowStyles.Add((New-Object RowStyle ([SizeType]::Percent), 100)) | Out-Null
    $MainPanel.RowStyles.Add((New-Object RowStyle ([SizeType]::Absolute), 50)) | Out-Null
    $MainPanel.ColumnStyles.Add((New-Object ColumnStyle)) | Out-Null
    $Form.Controls.Add($MainPanel)
    
    $Label = New-Object CustomControls.GrowLabel
    $Label.Dock = [DockStyle]::Fill
    $MainPanel.Controls.Add($Label)
    
    $ButtonPanel = New-Object Panel
    $ButtonPanel.Dock = [DockStyle]::Fill
    $MainPanel.Controls.Add($ButtonPanel)
    
    $OKButton = New-Object Button
    $OKButton.Anchor = [AnchorStyles]::Bottom + [AnchorStyles]::Right
    $OKButton.Location = New-Object Point ($ButtonPanel.Width - 160), 21
    $OKButton.Size = New-Object Size 75, 23
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [DialogResult]::OK
    $Form.AcceptButton = $OKButton
    $ButtonPanel.Controls.Add($OKButton)
    
    $CancelButton = New-Object Button
    $CancelButton.Anchor = [AnchorStyles]::Bottom + [AnchorStyles]::Right
    $CancelButton.Location = New-Object Point ($ButtonPanel.Width - 75), 21
    $CancelButton.Size = New-Object Size 75, 23
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [DialogResult]::Cancel
    $Form.CancelButton = $CancelButton
    $ButtonPanel.Controls.Add($CancelButton)
    
    $Label.Text = $Message
    $Result = $Form.ShowDialog()
    
    Write-Output ($Result -eq [DialogResult]::OK)
}