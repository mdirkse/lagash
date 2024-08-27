{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    awscli2
    clang
    gh
    git
    google-cloud-sdk
    jetbrains-toolbox
    jq
    k9s
    kubectl
    kubectx
    kubelogin-oidc
    meld
    shellcheck
    terraform
    postman
    yq-go

    # Java
    gradle
    jdk21

    # Rust
    rustup
    cargo-bloat
    cargo-geiger
    cargo-modules
    cargo-udeps
    cargo-watch
  ];

  # Set JAVA_HOME
  environment.variables.JAVA_HOME = "${pkgs.jdk21.home}/lib/openjdk";

  # Aliases
  programs.fish.shellAliases = {
    gralde = "gradle";
    gti = "git";
    k = "kubectl";
    kctx = "kubectx";
    kns = "kubens";
    tf = "terraform";
  };
}
