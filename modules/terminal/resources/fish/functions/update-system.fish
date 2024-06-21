function update-system
    cd /home/maarten/Source/lagash/
    sudo nix-channel --update
    nix flake update
    sudo nixos-rebuild switch --flake .#laptop --upgrade
    sudo nix-collect-garbage -d
    rustup update
end
