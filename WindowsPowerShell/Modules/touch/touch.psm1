
function touch([Parameter(ValueFromRemainingArguments=$true)][String[]]$file_names){
    <#
    .SYNOPSIS
        Creates a file so long as it doesn't already exist. If the file exists, it changes the last modified time to the current time. 
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
    foreach($name in $file_names){


        # If the file doesn't already exist
        # and if the dir supplied by name is valid (or no dir supplied)
        # then you create a new file
        if(!(Test-Path $name)) {
            $dir = Split-Path $name
            if(($dir -eq "") -or (Test-Path($dir))) {
                New-Item $name
            }
        }
        
        # Otherwise rewrite the modified date/time of a file that already exists
        elseif((Get-Item $name) -isnot [System.IO.DirectoryInfo]){
            (Get-ChildItem $name).LastWriteTime = Get-Date
        }
    }
    
}

Export-ModuleMember touch