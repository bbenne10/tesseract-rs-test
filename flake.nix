{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
  };
  outputs = {self, nixpkgs, flake-utils, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          craneLib = crane.lib.${system};
          buildInputs = with pkgs; [
            leptonica
            libiconv
            tesseract5
            pkgconfig
          ];
          tess_test_deps = craneLib.buildDepsOnly {
            inherit buildInputs;
            src = ./.;
            # Don't run the tests for all of our dependencies.
            # change if you want to.
            doCheck = false;
          };
      in {
        devShell = pkgs.mkShell ({
          # these are persistent inside the shell
          buildInputs =
            with pkgs; [
              rustc
              cargo
              clippy
              rustfmt
              rust-analyzer
          ] ++ buildInputs;
        });
        packages = {
          tess_test = craneLib.buildPackage {
            inherit buildInputs;
            pname = "tess_test";
            src = ./.;
            cargoArtifacts = tess_test_deps;
            doCheck = true;
          };
        };
      }
    );
}
