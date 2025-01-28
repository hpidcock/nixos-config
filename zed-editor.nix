{pkgs, lib, ...}:
let
  runscript = pkgs.writeShellScriptBin "zeditor" ''
    exec ${pkgs.nixgl.nixVulkanIntel}/bin/nixVulkanIntel ${pkgs.zed-editor}/bin/zeditor "$@"
  '';
in pkgs.symlinkJoin {
  name = "zeditor";
  paths = [ 
    runscript
    pkgs.zed-editor
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/zeditor --prefix PATH : $out/bin";
}

