function update-system
    sudo emerge --sync --quiet
    sudo emerge -uUDN @world
    sudo emerge --depclean
    sudo update_rubygems
    sudo gem update --system
    gcloud components update
    cargo install-update -a
    sudo /usr/sbin/ntpdate 0.nl.pool.ntp.org 1.nl.pool.ntp.org
    sudo ~/Source/lagash/applypuppet.sh
end
