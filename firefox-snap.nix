{pkgs, lib, ...}:
let
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

