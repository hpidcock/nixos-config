{pkgs, unstable-pkgs, pkgs-24-05, lib, ...}:
let
  mongo-4_4 = pkgs-24-05.callPackage ../mongodb/4.4.nix {
    sasl = pkgs-24-05.cyrus_sasl;
    boost = pkgs-24-05.boost179.override { enableShared = false; };
    inherit (pkgs-24-05.darwin) cctools;
    inherit (pkgs-24-05.darwin.apple_sdk.frameworks) CoreFoundation Security;
  };
  packages = with pkgs; [
    zsh
    (unstable-pkgs.go_1_23)
    yq-go
    jq
    gnumake
    gccStdenv
    gcc
    pkg-config
    bzip2
    shellcheck
    expect
    azure-cli
    shfmt
    graphviz
    (unstable-pkgs.snapcraft)
    (unstable-pkgs.rockcraft)
    (unstable-pkgs.charmcraft)
    (mongo-4_4)
  ];
  libs = with pkgs; [
    sqlite
  ];
  devPackages = map (lib.getOutput "dev") libs;
  libPackages = map (lib.getOutput "lib") libs;
in pkgs.runCommand "jdev" {
  buildInputs = packages;
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  for path in ${builtins.concatStringsSep " " (builtins.foldl' (paths: pkg: paths ++ (map (directory: "'${pkg}/${directory}/pkgconfig'") ["lib" "share"])) [ ] devPackages)}; do
    addToSearchPath JDEV_PKG_CONFIG_PATH "$path"
  done

  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/jdev
  wrapProgram $out/bin/jdev \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --suffix PKG_CONFIG_PATH : "$JDEV_PKG_CONFIG_PATH" \
    --suffix CGO_CFLAGS " " "${builtins.concatStringsSep " " (map (pkg: "-I${pkg}/include") devPackages)}" \
    --suffix CGO_LDFLAGS " " "${builtins.concatStringsSep " " (map (pkg: "-L${pkg}/lib") libPackages)}"

''
