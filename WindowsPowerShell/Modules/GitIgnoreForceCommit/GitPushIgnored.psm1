# If a gitignore is added retroactively or updated, this will force those ignores onto the project to allow them to be committed
function GitIgnoreForceCommit()
{
    git rm -r --cached .
    git add .
    git commit -m ".gitignore push"
}