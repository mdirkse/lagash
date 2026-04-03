{ ... }: {
  # Add encrypted files under ./secrets (or elsewhere), set defaultSopsFile, and declare
  # each key under sops.secrets. After first boot, publish the host age public key:
  #   nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt
  # then encrypt or re-encrypt with sops so that key can decrypt.
  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = { };
  };
}
