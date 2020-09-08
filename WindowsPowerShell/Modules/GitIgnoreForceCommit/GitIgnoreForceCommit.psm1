function GitIgnoreForceCommit()
{
    <#
    .SYNOPSIS
        If a gitignore is added retroactively or updated, this will force those ignores onto the project to allow them to be committed. 
        Make sure to use this in the folder in which the repository is located.
    #>
    git rm -r --cached .
    git add .
    git commit -m ".gitignore push"
}
