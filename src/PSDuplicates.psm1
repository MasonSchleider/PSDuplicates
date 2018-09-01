function Get-Duplicates {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path,
        
        [Switch]$UsingHash = $false,
        
        [Switch]$Interactive = $false
    )
    
    Begin {
        $FileList = New-Object System.Collections.ArrayList
    }
    
    Process {
        $Path | % {
            try {
                if (Test-Path -Path $_) {
                    $File = Get-Item -Path $_
                } elseif (Test-Path -LiteralPath $_) {
                    $File = Get-Item -LiteralPath $_
                } else {
                    throw
                }
            } catch {
                Write-Error "Cannot find path '$_' because it does not exist."
                return # Skip file system path
            }
            
            $FileList.Add($File) | Out-Null
        }
    }
    
    End {
        $FileTable = @{}
        $Activity = "Searching for duplicate files . . ."
        
        for ($i = 0; $i -lt $FileList.Count; $i++) {
            $PercentComplete = ($i + 1) / $FileList.Count * 100
            $Status = "Progress: {0}%" -f ([int]$PercentComplete)
            $CurrentOperation = "Processing file {0} / {1}" -f ($i + 1), $FileList.Count
            Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete $PercentComplete
            
            if ($UsingHash) {
                $key = (Get-FileHash -LiteralPath $FileList[$i].FullName).Hash
            } else {
                $key = $FileList[$i].Name
            }
            if ($FileTable.Contains($key)) {
                $FileTable[$key] += $FileList[$i]
            } else {
                $FileTable.Add($key, @($FileList[$i]))
            }
        }
        Write-Progress -Activity $Activity -Completed
        
        $Duplicates = $FileTable.GetEnumerator() | Where-Object {$_.Value.Count -gt 1}
        if ($Interactive) {
            $Columns = @(
                @{ Name = "Path"; Width = 365 },
                @{ Name = "Size"; Alignment = "Right" },
                "Last Modified"
            )
            $Properties = @(
                @{ Name = "Path"; Expression = { Resolve-Path -LiteralPath $_.FullName -Relative } },
                @{ Name = "Size"; Expression = { Get-FriendlySize $_.Length 2 } },
                @{ Name = "LastWriteTime"; Expression = { $_.LastWriteTime.ToString("MM/dd/yyyy hh:mm tt") } }
            )
            
            :ProcessSet foreach ($set in $Duplicates) {
                do {
                    $SelectedItems = Show-ListView "Duplicate File Set" $Columns ($set.Value | Select-Object -Property $Properties)
                    if ($SelectedItems -eq $null) { break ProcessSet }
                    if ($SelectedItems.Count -eq 0) { continue ProcessSet }
                    Write-Verbose ("`n" + (($SelectedItems | Out-String).Trim() -split "`n" | % { "    $_" } | Out-String))
                    
                    $Confirmation = $true
                    if ($SelectedItems.Count -eq $set.Value.Count) {
                        # Confirm deletion of all files
                        $Confirmation = Show-ConfirmDialog "Confirm File Deletion" "WARNING: All duplicate files in this set will be deleted. Proceed?"
                    }
                } while (!$Confirmation)
                
                # Delete selected files
                Remove-Item -LiteralPath ($SelectedItems | Select-Object -ExpandProperty Path) -WhatIf
            }
        } else {
            Write-Output $Duplicates
            
            #-- Useful Snippets --
            
            # Write the name of each duplicate file and the list of paths in which it is contained to a text document (brief output; best for duplicate searches based on filenames)
            #Add-Content .\Duplicates.txt ($Duplicates | % { $_.Name; ($_.Value | Select-Object -ExpandProperty FullName) -split "`n" | % { "    $_" }; "" })
            
            # Write the full path, size, and last write time of each duplicate file to a text document (detailed output; best for duplicate searches based on file hashes)
            #$Properties = @("FullName", @{ Name = "Size"; Expression = { (Get-FriendlySize $_.Length 2).PadLeft(8, ' ') } }, "LastWriteTime")
            #Add-Content .\Duplicates.txt -Value ($Duplicates | % { $_.Value | Select-Object -Property $Properties; "" } | Out-String).TrimEnd()
            
            # Display the total disk space that could be freed by deleting all duplicate files (leaving a single copy of each file)
            #$TotalSize = 0; $Duplicates | % { $TotalSize += (($_.Value | Select-Object -ExpandProperty Length) | Measure-Object -Maximum).Maximum }; Get-FriendlySize $TotalSize 2
        }
    }
}