<# 
.SYNOPSIS
Get a folder tree in vCenter and return a hashtable of hashtables.

.DESCRIPTION
From a given root folder, all folders are collected from vCenter and stored in
a hashtable with their respective parent/child relationship. This hashtable can
be converted to JSON for use elsewhere.

.NOTES
Author: Lucas McGlamery
Version:
1.0 2023-07-03  Initial release

.PARAMETER RootFolderString
Root folder name for tree to start in. Default is the builtin vm folder, ID 
Folder-group-v4.

.EXAMPLE
Get-FolderTree

.EXAMPLE
$FolderTreeJSON = Get-FolderTree -RootFolderString 'region1' | ConvertTo-Json -Depth 10
#>
function Get-FolderTree () {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Root folder name for tree to start in. Default is the builtin vm folder.')]
        [String]
        $RootFolderString
    )

    if (!$Global:DefaultVIServer) {
        echo "Not connected to a vCenter Server system. Please connect and try again."
        break
    }

    if (!$RootFolderString) {
        $ParentFolder = $(Get-Folder -Location $(Get-Folder -Id 'Folder-group-v4') -NoRecursion)
    } else {
        if (!$(Get-Folder $RootFolderString)) {
            echo "Folder is not valid. Please correct the name and try again."
            break
        } else {
            $ParentFolder = $(Get-Folder -Location $RootFolderString -NoRecursion)
        }
    }

    $FolderTree = @{}
    $CurrentTreeParent = '$FolderTree'

    function Get-Folders($Parent) {

        $Parent | ForEach-Object -Begin {
            $Count = 0
        } -Process {
            $Object = $_

            if (0 -ne $Count) {
                $Count--
                $CurrentTreeParent = $CurrentTreeParent -replace '\["[^"]+"\](\s*\]\["[^"]+"\])*$', ''
            }
            $(Invoke-Expression -Command $CurrentTreeParent).Add($Object.Name, @{})

            if (0 -ne $Object.ExtensionData.ChildEntity.Count -and $Object.ExtensionData.ChildEntity.Type -contains 'Folder') {
                $Count += $($Object.ExtensionData.ChildEntity.Count)
                $ChildFolder = $(Get-Folder -Location $(Get-Folder -Id "Folder-$($Object.ExtensionData.MoRef.Value)") -NoRecursion)
                $CurrentTreeParent = $CurrentTreeParent+'["'+$Object.Name+'"]'
                Get-Folders $ChildFolder
            }
        }
    }
    Get-Folders $ParentFolder
    return $FolderTree
}