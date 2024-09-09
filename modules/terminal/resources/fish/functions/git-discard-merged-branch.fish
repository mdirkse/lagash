function git-discard-merged-branch
    set merged_branch (git rev-parse --abbrev-ref HEAD)

    if test $merged_branch = "master" || test $merged_branch = "main"
        echo "Let's not delete the main/master branch, shall we?"
        return 1
    end

    git co master
    git pull -p
    git branch -D $merged_branch
end
