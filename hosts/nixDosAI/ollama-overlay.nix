self: super: {
  ollama-overlay = super.stdenv.mkDerivation rec {
    pname = "ollama-cuda";
    version = "0.5.11";

    src = let
      arch = super.stdenv.hostPlatform.uname.processor;
      mappedArch = {
        "x86_64" = "amd64";
        "aarch64" = "arm64";
      }.${arch} or (throw "Unsupported architecture: ${arch}");
    in super.fetchurl {
      url = "https://ollama.com/download/ollama-linux-${mappedArch}.tgz?version=${version}";
      # in "https://ollama.com/download/ollama-linux-${mappedArch}.tgz";
      # Replace with actual hash using nix-prefetch-url
      sha256 = "sha256-qjhs4cMUaGEz96vptWHz7yMPA/iLvdH1g8lRxKtTeK0=";
      name = "ollama-linux-${mappedArch}-${version}.tgz";
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
      tar xzf $src -C $out --strip-components=0
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
