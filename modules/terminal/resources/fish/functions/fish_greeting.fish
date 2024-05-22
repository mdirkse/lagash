function fish_greeting
    set_color $fish_color_autosuggestion
    command $HOME/bin/uptime-procps -p
    set_color normal
end
