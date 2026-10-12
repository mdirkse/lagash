function aws-creds
    if ! count $argv > /dev/null
        echo "Please provide a profile"
    end

    aws configure list-profiles | grep "^$argv[1]\$" > /dev/null
    if test $status -ne 0
        echo "No profile named \"$argv[1]\" found"
        return 1
    end

    aws sts get-caller-identity --profile "$argv[1]" > /dev/null
    if test $status -ne 0
        echo "Not logged in. Fetching profile credentials..."
        aws sso login --profile "$argv[1]"
        if test $status -ne 0
            echo "Failed to login"
            return 1
        end
    else
        echo "Already logged in."
    end

    echo "Setting credentials in shell..."

    set cmd_output (eval aws configure export-credentials --profile "$argv[1]" --format env)
    for line in $cmd_output
        if string match -rq '^export [^\=]+=.+' $line
            set var_name (string replace "export " "" (string split -m1 "=" $line)[1])
            set var_value (string split -m1 "=" $line)[2]

            set -gx $var_name $var_value
        else
            echo "Error: Line doesn't match expected format: $line"
        end
    end

    echo "Done!"
end
