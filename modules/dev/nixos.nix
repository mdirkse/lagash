{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  jdk = pkgs.jdk25;
in
{
  programs.java = {
    enable = true;
    package = jdk;
  };

  environment.systemPackages = with pkgs; [
    awscli2
    gh
    git
    google-cloud-sdk
    jq
    k9s
    kubectl
    kubectx
    kubelogin-oidc
    shellcheck
    serie
    terraform
    yq-go

    # Java
    gradle_9
    jdk

    # Rust
    gcc
    mold
  ];

  environment.variables.JAVA_HOME = "${jdk.home}/lib/openjdk";
  environment.variables.GRADLE_OPTS = "-Dorg.gradle.java.home=${jdk.home}/lib/openjdk -Dorg.gradle.java.installations.auto-download=false";
  environment.variables.TF_PLUGIN_CACHE_DIR = "/home/maarten/.terraform.d/plugin-cache";

  # Aliases
  programs.fish.shellAliases = {
    gralde = "gradle";
    g = "git";
    k = "kubectl";
    kctx = "kubectx";
    kns = "kubens";
    tf = "terraform";
  };
}
