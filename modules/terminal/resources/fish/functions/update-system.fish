function update-system
    pushd 2> /dev/null
    cd /home/maarten/Source/lagash/
    sudo nix-channel --update
    nix flake update
    sudo nixos-rebuild switch --flake .#laptop --upgrade
    rustup update
    rm -fr "/home/maarten/Pictures/screenshots/*"
    popd 2> /dev/null || true
end
