{pkgs, lib, ...}:
let
  packages = with pkgs; [
  ];
  libs = with pkgs; [
  ];
  devPackages = map (lib.getOutput "dev") libs;
  libPackages = map (lib.getOutput "lib") libs;
  ffscript = pkgs.writeShellScriptBin "firefox" ''
    unset __EGL_VENDOR_LIBRARY_FILENAMES
    exec /usr/bin/firefox "$@"
  '';
in pkgs.symlinkJoin {
  name = "firefox";
  paths = [ ffscript ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/firefox --prefix PATH : $out/bin";
}

