# Tesseract-rs Flake test

Grabs tesseract5 and leptonica from nixpkgs
and sets up a crate that build against them.

With nix available,
clone the repo,
cd inside and run
`nix develop .#tess_test`.

Once inside the devShell, 
your general rust packages are available
(via nix pkgs - no need for rustup).

You can compile with:

```console
$ nix build .#tess_test
``` 

which will put results in the symlink at `./result`

Builds done this way will cache and reuse dependencies 
by caching them in the nix store and providing them
as an input if the array of deps in `Cargo.toml` has not changed.


You may also build with: 

```console
$ cargo build
```

which does the normal rust thing of putting it in `/target/...`
and caching as all other "normal" rust development toolchains do
(since you're using one :) ).

