function screenshot
    set SDATE (date +'%Y-%m-%d-%H-%M-%S')
    set SFILE "$HOME/Pictures/screenshots/screenshot-$SDATE.png"
    grim -g (slurp) "$SFILE"
    wl-copy < "$SFILE"
end
