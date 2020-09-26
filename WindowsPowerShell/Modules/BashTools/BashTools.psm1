function nixpath($path) {
    <#
        .DESCRIPTION
            Returns the unix path of a windows directory for windows subsystem for linux
    #>
    $str = ""
    if(split-path $path -IsAbsolute)
    {
        $str += "/mnt/"
    }
    return ($str + (($path -replace "\\","/") -replace ":","").ToLower().Trim("/"))
}

function nano($path) {
    bash -c "nano $(nixpath $path)"
}

function vi($path) 
{
    bash -c "vi $(nixpath $path)"
}

<#
    Author: Natalie Dorshimer
#>
function touch([Parameter(ValueFromRemainingArguments=$true)][String[]]$args){
    <#
    .SYNOPSIS
        Wrapper for the bash command "touch" 
    .PARAMETER file_names
        Space separated (or array) of names of files and their paths that you would like to create
    .EXAMPLE
        PS C:\Users\Natalie> touch file1 file2 file3


        Directory: C:\Users\Natalie


        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----          9/8/2020   3:26 PM              0 file1
        -a----          9/8/2020   3:26 PM              0 file2
        -a----          9/8/2020   3:26 PM              0 file3


    .EXAMPLE
        PS C:\Users\Natalie> touch Downloads\file1


        Directory: C:\Users\Natalie\Downloads


        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----          9/8/2020   3:27 PM              0 file1
    #>

    $command = "touch "
    foreach($arg in $args) {
        $command += $($arg + " ")    
    }
    bash -c $command
    
}


Export-Function nixpath, nano, vi, touch
