function fish_greeting -d "What's up, fish?"
    set_color $fish_color_autosuggestion
    command -s uptime >/dev/null
    and command uptime -p
    set_color normal
end
