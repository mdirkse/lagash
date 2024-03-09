function update-system
    sudo nix-channel --update
    sudo nixos-rebuild switch --flake /home/maarten/Source/lagash/.#laptop --upgrade
    sudo nix-collect-garbage -d
    rustup update
end
