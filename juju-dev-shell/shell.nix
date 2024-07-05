{pkgs, lib, ...}:
let
  packages = with pkgs; [
    zsh
    go
    yq
    jq
    gnumake
    gccStdenv
    gcc
    pkg-config
    bzip2
    mongodb-5_0
    shellcheck
    expect
    azure-cli
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
