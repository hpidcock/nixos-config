{ pkgs, lib, jdev, zed-editor, ... }:
let
  runscript = pkgs.writeShellScriptBin "jdev-zeditor" ''
    exec ${jdev}/bin/jdev -c 'exec ${zed-editor}/bin/zeditor "$@"'
  '';
in pkgs.symlinkJoin {
  name = "jdev-zeditor";
  paths = [ runscript zed-editor jdev ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/jdev-zeditor --prefix PATH : $out/bin";
}
