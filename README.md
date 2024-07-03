## Synopsis
Get a folder tree in vCenter and return a hashtable of hashtables.

## Usage
```
Import-Module .\get-foldertree.ps1
Get-FolderTree
# or
$FolderTreeJSON = Get-FolderTree -RootFolderString 'region1' | ConvertTo-Json -Depth 10
```

![](https://github.com/L-McG/get-foldertree/blob/main/Animation.gif)