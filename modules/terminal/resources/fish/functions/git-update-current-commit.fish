function git-update-current-commit
    git commit -a --amend --no-edit
    git push -f origin (git rev-parse --abbrev-ref HEAD)
end
