# PowerShell.GetDuplicates

> **Note:** This module is a work in progress!

PSDuplicates is a PowerShell module for identifying duplicate files.

It can detect duplicate files using one of two methods:

1. Filename comparison.
2. Checksum comparison (using SHA-256).

The module also includes an optional GUI with which duplicate files can be viewed and deleted.

## Usage

Retrieve a hash table containing the results of a duplicate file search (for manual processing):

```powershell
$Duplicates = Get-ChildItem . -File -Recurse | Get-Duplicates
```

Search for duplicate files by checksum (slower, but more accurate and thorough):

```powershell
$Duplicates = Get-ChildItem . -File -Recurse | Get-Duplicates -UsingHash
```

View search results via GUI (Remove-Item currently uses the `WhatIf` parameter):

```powershell
Get-ChildItem . -File -Recurse | Get-Duplicates -Interactive
```
