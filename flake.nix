{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
  };
  outputs = { self, nixpkgs, flake-utils, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.lib.${system};
        buildInputs = with pkgs; [ leptonica libiconv tesseract5 pkgconfig ];
        LIBCLANG_PATH= pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
        BINDGEN_EXTRA_CLANG_ARGS = [
          ''-I"${pkgs.glibc.dev}/include"''
          ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
          ];
        tess_test_deps = craneLib.buildDepsOnly {
          inherit buildInputs LIBCLANG_PATH BINDGEN_EXTRA_CLANG_ARGS;
          src = ./.;
          # Don't run the tests for all of our dependencies.
          # change if you want that behavior.
          doCheck = false;
        };
      in {
        devShell = pkgs.mkShell ({
          # These get exposed as env vars in the devShell
          inherit LIBCLANG_PATH BINDGEN_EXTRA_CLANG_ARGS;

          # these are persistent inside the shell
          buildInputs = with pkgs;
            [ rustc cargo clippy rustfmt rust-analyzer ] ++ buildInputs;
        });
        packages = {
          tess_test = craneLib.buildPackage {
            inherit buildInputs LIBCLANG_PATH BINDGEN_EXTRA_CLANG_ARGS;
            pname = "tess_test";
            src = ./.;
            cargoArtifacts = tess_test_deps;
            doCheck = true;
          };
        };
      });
}
