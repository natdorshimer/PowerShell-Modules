
function touch([Parameter(ValueFromRemainingArguments=$true)][String[]]$file_names){
    <#
    .SYNOPSIS
        Creates a file so long as it doesn't already exist. Unlike Linux touch, the file's recent date is not updated
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
        #If the file doesn't already exist
        if(!(Test-Path $file_names)) {
            #If the directory it wants to be in already exists
            $dir = Split-Path $name
            if(($dir -eq "") -and !($name -eq "")) {
                $dir = "."
            }
            if((Test-Path($dir))) {
                New-Item $name
            }
        }
    }
    
}

Export-ModuleMember touch