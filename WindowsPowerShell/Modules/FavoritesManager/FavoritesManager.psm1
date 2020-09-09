<#
    Author: Natalie Dorshimer 
    email:  dorshimer.natalie@gmail.com
    Last Edited: 9/5/2020
#>

<# Script Variables #>
# This needs to be ordered so that when we sort the keys they remain in the place they should be
New-Variable -Name favs_dict -Value (New-Object Collections.Specialized.OrderedDictionary) -Scope Script -Force

<# Public Interface#>

function cdf([string] $alias, [switch]$add, [switch]$remove, 
            [switch]$path, [switch]$clear, [switch]$list, [switch]$open)
{
    <#
    .SYNOPSIS
        Interface for creating and removing favorites to quickly change directories to

    .DESCRIPTION
        Provides an interface for managing a list of favorited directories to quickly switch to. The list of favorites is saved in favorites.txt located in (Split-Path $profile).
        There is an autocomplete by pressing tab when selecting a directory to make cdf easier to use

        PS C:\> cdf 
            lists favorites

        PS C:\Users\Natalie> cdf -add
            Will add the current directory and the name of the directory to the list of favorites

        PS C:\ cdf Natalie -path 
            Returns 'PS C:\Users\Natalie', the directory saved to the key 'Natalie

        PS C:\> cdf Natalie
            Changes directory to 'PS C:\Users\Natalie' since Natalie is saved in my list

    .PARAMETER alias
        The name of the favorite you wish to perform a command on.
    .PARAMETER add
        Switch for adding the selected alias (or name of current directory if none is selected) to the favorites list
    .PARAMETER remove
        Switch for removing the selected alias (or name of current dir if none selected) from the favs list
    .PARAMETER clear
        Clears list of favorites if selected. Asks for user confirmation
    .PARAMETER path
        Switch for returning the path that the selected alias points to. This has higher priority than -list and nullifies -list if selected
    .PARAMETER list
        Returns the favorites dictionary if selected. cdf -list is the same thing as 'cdf' if no other commands are used
    .PARAMETER open
        Opens up favorites.txt in a text editor if selected

    .EXAMPLE
        cdf 
        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        Documents                      C:\Users\Natalie\Documents
        Downloads                      C:\Users\Natalie\Downloads
        GD                             C:\Users\Natalie\Google Drive
        go_prac                        C:\Users\Natalie\code\go\src\go_prac
        GoogleDrive                    C:\Users\Natalie\Google Drive
        natalie                        C:\Users\Natalie
        PS_Modules                     C:\Users\Natalie\Documents\WindowsPowerShell\Modules
        python                         C:\Users\Natalie\code\python
        Spectrogram                    C:\Users\Natalie\VS Dev\source\repos\Spectrogram Plus\Spectrogram Plus
        Videos                         C:\Users\Natalie\Videos
        VS_Projects                    C:\Users\Natalie\VS Dev\source\repos
        VSPath                         C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE
        WindowsPowerShell              C:\Users\Natalie\Documents\WindowsPowerShell
        
    .EXAMPLE
        PS C:\Users\Natalie> cdf Spectrogram

        PS C:\Users\Natalie\VS Dev\source\repos\Spectrogram Plus\Spectrogram Plus>
        
    .EXAMPLE
        PS C:\Users\Natalie> cdf Spectrogram -fav

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        Documents                      C:\Users\Natalie\Documents
        Downloads                      C:\Users\Natalie\Downloads
        GD                             C:\Users\Natalie\Google Drive
        go_prac                        C:\Users\Natalie\code\go\src\go_prac
        WindowsPowerShell              C:\Users\Natalie\Documents\WindowsPowerShell


        PS C:\Users\Natalie\VS Dev\source\repos\Spectrogram Plus\Spectrogram Plus>
    .EXAMPLE
        PS C:\Users\Natalie> cdf -clear
        Are you sure you want to delete your favorites? (y/n): y


            Directory: C:\Users\Natalie\Documents\WindowsPowerShell


        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----          9/5/2020  12:49 PM              0 favorites.txt
        PS C:\Users\Natalie> cdf
        PS C:\Users\Natalie>

    .EXAMPLE
        PS C:\Users\Natalie> cdf

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        GD                             C:\Users\Natalie\Google Drive


        PS C:\Users\Natalie> cdf GD -remove 
        PS C:\Users\Natalie> cdf

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code

    .EXAMPLE
        cdf -open
        Opens favorites.txt 

    .EXAMPLE
        PS C:\Users\Natalie> cdf

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        Spectrogram                    C:\Users\Natalie\VS Dev\source\repos\Spectrogram Plus\Spectrogram Plus


        PS C:\Users\Natalie> cdf Spectrogram -path 
        C:\Users\Natalie\VS Dev\source\repos\Spectrogram Plus\Spectrogram Plus
    .EXAMPLE
        PS C:\Users\Natalie\Pictures> cdf

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        Documents                      C:\Users\Natalie\Documents


        PS C:\Users\Natalie\Pictures> cdf -add
        PS C:\Users\Natalie\Pictures> cdf

        Name                           Value
        ----                           -----
        code                           C:\Users\Natalie\code
        Documents                      C:\Users\Natalie\Documents
        Pictures                       C:\Users\Natalie\Pictures

    #>
    Update-Dictionary
    if($clear) {
        Clear-Favorites
        break
    }
    
    
    if($add) { Add-Favorite $alias }

    if($remove){ cdf_delete($alias)  }

    if($open){ Invoke-Item (Get-FavoritesPath) }

    if($alias -and !$remove) {
        # If the path is legitimate it defaults to 'cd $alias'
        if(Test-Path $alias) { 
            Set-Location $alias 
        } 
        else { 
            Set-Location ($script:favs_dict[$alias]) 
        }
    }

    if($path) {
        return $script:favs_dict[$alias]
    }
    
    if((!$alias -and !$open -and !$remove -and !$add) -or $list) {
        return Get-Favorites
    }
}

<# Autocomplete Feature #>
$scriptblock = {
    param($commandName, $parameterName, $match)
    
    $script:favs_dict.Keys -like "$match*"
}
Register-ArgumentCompleter -CommandName cdf -ParameterName alias -ScriptBlock $scriptBlock


<# Private helper interface #>

function Get-Favorites() { return $script:favs_dict }

function Get-FavoritesPath() { return (Split-Path $profile) + ('\favorites.txt') }

function Get-FavoritesFile() { return Get-Content (Get-FavoritesPath) }

function CurrentDirName() { return Split-Path -leaf -path (Get-Location) }

function Clear-Favorites()
{
    $confirmation = Read-Host "Are you sure you want to delete your favorites? (y/n)"
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        Remove-Item (Get-FavoritesPath) # Erase txt file
        New-Item (Get-FavoritesPath) # Create a new one
        Update-Dictionary # Update favs_dict and then write it to favorites.txt
    }
}

function cdf_delete($alias)
{
    if(!$alias) { 
        $alias = CurrentDirName
    }

    <# Deletes $alias or current directory name from the dictionary and updates favorites.txt #>
    if($script:favs_dict.Contains($alias))
    {
        $script:favs_dict.Remove($alias)
        Write-Dict-To-File
    }
}

function clear_dict()
{
    <# Clears the dictionary of favorites #>
    if($script:favs_dict.keys.length -gt 0)
    {
        $keys = New-Object System.Collections.ArrayList
        foreach($key in $script:favs_dict.Keys){ $null = $keys.Add($key) }
        foreach($i in $keys)
        {
            $script:favs_dict.Remove($i)
        }
    }
}


function Update-Dictionary()
{ 
    <# Clears the favorites dictionary and then updates it with the favorites in favorites.txt #>
    clear_dict

    $script:scriptBlock = {}
    $newDict = @{}
    foreach($key_val in Get-FavoritesFile)
    {
        $split = $key_val.split(',')
        $key = $split[0]
        $val = $split[1]
        $newDict[$key] = $val
    }

    $keys = New-Object System.Collections.ArrayList
    foreach($key in $newDict.Keys) { 
        [void]$keys.Add($key) 
    }

    # Sort the keys and then add the entries to the favorites dict
    foreach($i in ($keys | Sort-Object))
    {
        $script:favs_dict.Add($i, $newDict[$i])
    }


}

function Add-Favorite([string] $name)
{
    <#
        Adds the current directory with the alias of $name to favorites dict
        Then it updates favorites.txt with the updated favorites dict

        If $name is already an alias, it ovewrites the current alias
    #>
    if($name){
        $alias = $name
    }
    else{
        $alias = CurrentDirName
    }

    $loc = (Get-Location).tostring()
    $script:favs_dict[$alias] = $loc
    Write-Dict-To-File
}

function Write-Dict-To-File()
{
    <# Writes the current favs_dict to favorites.txt to keep it updated #>
    Remove-Item (Get-FavoritesPath)
    $file_str = ""
    foreach($key in $script:favs_dict.Keys)
    {
        if($file_str) { $file_str += "`n" }
        $file_str += $key + "," + $script:favs_dict[$key]
    }

    $file_str | out-file (Get-FavoritesPath)
}

Update-Dictionary # To make sure that $favs_dict is updated and autocomplete works when PowerShell is started up
Export-ModuleMember -Function cdf

