{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    awscli2
    clang
    git
    google-cloud-sdk
    jetbrains.idea-community
    jetbrains.rust-rover
    jq
    k9s
    kubectl
    kubectx
    kubelogin-oidc
    shellcheck
    terraform
    postman

    # Java
    gradle
    jdk21

    # Rust
    cargo
    cargo-bloat
    cargo-geiger
    cargo-modules
    cargo-udeps
    cargo-watch
    rustup
  ];

  # Set JAVA_HOME
  environment.variables.JAVA_HOME = "${pkgs.jdk21.home}/lib/openjdk";

  # Aliases
  programs.fish.shellAliases = {
    gralde = "gradle";
    k = "kubectl";
    kctx = "kubectx";
    kns = "kubens";
    tf = "terraform";
  };
}
