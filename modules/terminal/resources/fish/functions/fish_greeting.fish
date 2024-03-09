function fish_greeting
    set_color $fish_color_autosuggestion
    command -s uptime >/dev/null
    and eval (nix derivation show nixpkgs#procps | jq -r .[].outputs.out.path)/bin/uptime -p
    set_color normal
end
