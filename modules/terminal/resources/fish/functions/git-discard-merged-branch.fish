function git-discard-merged-branch
    set merged_branch (git rev-parse --abbrev-ref HEAD)
    git co master
    git pull -p
    git branch -D $merged_branch
end
