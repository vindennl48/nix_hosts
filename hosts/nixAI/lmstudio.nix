{ lib, stdenv, callPackage, fetchurl, appimageTools, ... }:
let
  pname = "lmstudio";
  version = "0.3.9";  # Updated version
  rev = "6";          # Update rev based on the release
  meta = {
    description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
    homepage = "https://lmstudio.ai/";
    license = lib.licenses.unfree;
    mainProgram = "lmstudio";
    maintainers = with lib.maintainers; [ cig0 eeedean crertel ];
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
  src = fetchurl {
    url = "https://installers.lmstudio.ai/linux/x64/${version}-${rev}/LM-Studio-${version}-${rev}-x64.AppImage";
    sha256 = "sha256-L3wYMqyjUL5pTz+/ujn76YYIfWzjqa3eoyNblU8/5hs="; # Get from error message when using an empty hash ""
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit meta pname version src;
  extraPkgs = pkgs: [ pkgs.ocl-icd ];
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
    install -m 444 -D ${appimageContents}/lm-studio.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/lm-studio.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=lmstudio'
  '';
}
