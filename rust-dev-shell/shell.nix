{pkgs, lib, ...}:
let
  packages = with pkgs; [
    zsh
    git
    rustc
    cargo
    gnumake
    gccStdenv
    gcc
    pkg-config
  ];
  libs = with pkgs; [
  ];
  devPackages = map (lib.getOutput "dev") libs;
  libPackages = map (lib.getOutput "lib") libs;
in pkgs.runCommand "zsh-rust-dev" {
  buildInputs = packages;
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  for path in ${builtins.concatStringsSep " " (builtins.foldl' (paths: pkg: paths ++ (map (directory: "'${pkg}/${directory}/pkgconfig'") ["lib" "share"])) [ ] devPackages)}; do
    addToSearchPath RDEV_PKG_CONFIG_PATH "$path"
  done

  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/zsh-zsh-rust-dev
  wrapProgram $out/bin/zsh-rust-dev \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --suffix PKG_CONFIG_PATH : "$RDEV_PKG_CONFIG_PATH" \
    --suffix CGO_CFLAGS " " "${builtins.concatStringsSep " " (map (pkg: "-I${pkg}/include") devPackages)}" \
    --suffix CGO_LDFLAGS " " "${builtins.concatStringsSep " " (map (pkg: "-L${pkg}/lib") libPackages)}"

''
