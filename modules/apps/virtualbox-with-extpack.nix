# VirtualBox host package with Oracle extpack in a separate derivation (manual
# unpack). Avoids tying extpack updates to the main virtualbox compile; the
# helper app cannot install into a copied tree (store-path checks).
{ lib, pkgs }:
let
  inherit (pkgs) stdenv virtualbox virtualboxExtpack;
  extpackDirName = "Oracle_VirtualBox_Extension_Pack";
in
lib.makeOverridable (
  {
    enableHardening ? true,
    headless ? false,
    enableWebService ? false,
    enableKvm ? false,
    extensionPack ? null,
    ...
  }@args:
  assert extensionPack == null;
  let
    base = virtualbox.override {
      inherit enableHardening headless enableWebService enableKvm;
      extensionPack = null;
    };
    share = if enableHardening then "share/virtualbox" else "libexec/virtualbox";
    extpackTree = pkgs.runCommand "virtualbox-extpack-${virtualboxExtpack.version}" { } ''
      mkdir -p "$out/${share}/ExtensionPacks/${extpackDirName}"
      ${stdenv.shell} -c 'cd "$out/${share}/ExtensionPacks/${extpackDirName}" && tar -xzf ${virtualboxExtpack}'
    '';
  in
  pkgs.symlinkJoin {
    name = "virtualbox-${base.version}-with-extpack";
    inherit (base) version;
    paths = [ base extpackTree ];
    passthru = base.passthru // { extensionPack = virtualboxExtpack; };
  }
) { }
