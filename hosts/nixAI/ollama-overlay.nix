self: super: {
  ollama-fix = super.stdenv.mkDerivation rec {
    pname = "ollama-cuda";
    version = "latest";

    src = super.fetchurl {
      url = let
        arch = super.stdenv.hostPlatform.uname.processor;
        mappedArch = {
          "x86_64" = "amd64";
          "aarch64" = "arm64";
        }.${arch} or (throw "Unsupported architecture: ${arch}");
      in "https://ollama.com/download/ollama-linux-${mappedArch}.tgz";
      # Replace with actual hash using nix-prefetch-url
      sha256 = "sha256-jU4FS8US1TEVB0wZ3lp5Fd94GA+JwBSruuRJfkqBOjw=";
    };

    nativeBuildInputs = [
      super.autoPatchelfHook
      super.makeWrapper
      super.gnutar
      super.gzip
    ];

    buildInputs = with super; [
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
      cudaPackages.cuda_nvcc
      cudaPackages.cudnn
      cudaPackages.libcufft
      cudaPackages.libcurand
      # Add these if needed for core functionality:
      stdenv.cc.cc.lib
      zlib
      libdrm
    ];

    unpackPhase = ''
      runHook preUnpack
      mkdir -p $out
      tar xzf $src -C $out --strip-components=1
      # Remove ROCm components if only CUDA is needed
      rm -rf $out/lib/ollama/runners/rocm_*
      runHook postUnpack
    '';

    dontInstall = true;

    postFixup = ''
      wrapProgram $out/bin/ollama \
        --prefix LD_LIBRARY_PATH : ${super.lib.makeLibraryPath [
          super.cudaPackages.cuda_cudart
          super.cudaPackages.libcublas
          super.cudaPackages.cudnn
          super.cudaPackages.libcufft
        ]}:/run/opengl-driver/lib
    '';

    meta = with super.lib; {
      description = "Ollama language model runner";
      homepage = "https://ollama.com";
      license = licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "ollama";
    };
  };
}

# self: super: {
#   ollama-fix = super.stdenv.mkDerivation rec {
#     pname = "ollama";
#     version = "latest";
#
#     src = super.fetchurl {
#       url = let
#         arch = super.stdenv.hostPlatform.uname.processor;
#         mappedArch = {
#           "x86_64" = "amd64";
#           "aarch64" = "arm64";
#         }.${arch} or (throw "Unsupported architecture: ${arch}");
#       in "https://ollama.com/download/ollama-linux-${mappedArch}.tgz";
#       # Replace with actual hash using nix-prefetch-url
#       sha256 = "sha256-jU4FS8US1TEVB0wZ3lp5Fd94GA+JwBSruuRJfkqBOjw=";
#     };
#
#     nativeBuildInputs = [
#       super.autoPatchelfHook
#       super.makeWrapper
#       super.gnutar
#       super.gzip
#     ];
#
#     buildInputs = with super.cudaPackages; [
#       cuda_cudart
#       libcublas
#       # Add other required CUDA packages here if needed
#     ];
#
#     installPhase = ''
#       mkdir -p $out/bin
#       mkdir -p ./unpacked
#       tar xzf $src --directory ./unpacked
#       mv ./unpacked/ollama $out/bin/
#       mv ./unpacked/lib/ollama $out/lib/
#     '';
#
#     meta = with super.lib; {
#       description = "Ollama language model runner";
#       homepage = "https://ollama.com";
#       license = licenses.mit;
#       platforms = [ "x86_64-linux" ];
#       mainProgram = "ollama";
#     };
#   };
# }


################################################################################
################################################################################
################################################################################


# self: super: {
#   ollama-cuda-fix = super.stdenv.mkDerivation rec {
#     pname = "ollama-cuda";
#     version = "0.5.7";
#
#     src = super.fetchurl {
#       url = let
#         arch = super.stdenv.hostPlatform.uname.processor;
#         mappedArch = {
#           "x86_64" = "amd64";
#           "aarch64" = "arm64";
#         }.${arch} or (throw "Unsupported architecture: ${arch}");
#       in "https://ollama.com/download/ollama-linux-${mappedArch}.tgz";
#       # Get hash via: nix-prefetch-url "https://ollama.com/download/ollama-linux-amd64.tgz"
#       hash = "sha256-jU4FS8US1TEVB0wZ3lp5Fd94GA+JwBSruuRJfkqBOjw=";
#     };
#
#     nativeBuildInputs = [
#       super.autoPatchelfHook
#       super.makeWrapper
#       super.gnutar
#       super.gzip
#     ];
#
#     buildInputs = with super.cudaPackages; [
#       cuda_cudart
#       libcublas
#     ];
#
#     # Explicit unpack command
#     unpackPhase = ''
#       runHook preUnpack
#       mkdir -p $out
#       tar xzf $src -C $out --strip-components=1
#       runHook postUnpack
#     '';
#
#     # No need for installPhase since we unpack directly to $out
#     dontInstall = true;
#
#     postFixup = ''
#       wrapProgram $out/bin/ollama \
#         --prefix LD_LIBRARY_PATH : ${super.lib.makeLibraryPath [
#           super.cudaPackages.cuda_cudart
#           super.cudaPackages.libcublas
#         ]}
#     '';
#
#     meta = with super.lib; {
#       description = "Ollama with CUDA support using precompiled binaries";
#       homepage = "https://ollama.com";
#       license = licenses.mit;
#       platforms = [ "x86_64-linux" "aarch64-linux" ];
#       mainProgram = "ollama";
#     };
#   };
# }

# self: super: {
#   ollama-cuda-fix = super.stdenv.mkDerivation rec {
#     pname = "ollama-cuda";
#     version = "0.5.7";
#
#     src = super.fetchurl {
#       url = let
#         arch = super.stdenv.hostPlatform.uname.processor;
#         mappedArch = {
#           "x86_64" = "amd64";
#           "aarch64" = "arm64";
#         }.${arch} or (throw "Unsupported architecture: ${arch}");
#       in "https://ollama.com/download/ollama-linux-${mappedArch}.tgz?version=${version}";
#       # Get the correct hash using: nix-prefetch-url "https://ollama.com/download/ollama-linux-${mappedArch}.tgz?version=0.5.7"
#       hash = "sha256-jU4FS8US1TEVB0wZ3lp5Fd94GA+JwBSruuRJfkqBOjw="; # Replace with actual hash
#     };
#
#     nativeBuildInputs = [
#       super.autoPatchelfHook
#       super.makeWrapper
#     ];
#
#     buildInputs = with super.cudaPackages; [
#       cuda_cudart
#       libcublas
#     ];
#
#     installPhase = ''
#       mkdir -p $out/bin
#       install -Dm755 ollama $out/bin/ollama
#
#       if [ -d lib ]; then
#         mkdir -p $out/lib
#         cp -r lib/* $out/lib/
#       fi
#
#       wrapProgram $out/bin/ollama \
#         --prefix LD_LIBRARY_PATH : ${super.lib.makeLibraryPath [
#           super.cudaPackages.cuda_cudart
#           super.cudaPackages.libcublas
#         ]}
#     '';
#
#     meta = with super.lib; {
#       description = "Ollama with CUDA support using precompiled binaries";
#       homepage = "https://ollama.com";
#       license = licenses.mit;
#       platforms = [ "x86_64-linux" "aarch64-linux" ];
#       mainProgram = "ollama";
#     };
#   };
# }
