function g-update-current-commit
    git commit -a --amend --no-edit
    git push --force-with-lease origin (git rev-parse --abbrev-ref HEAD)
end
