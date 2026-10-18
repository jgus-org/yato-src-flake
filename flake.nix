{
  description = "Yato header-only template library source, pinned for the freeimage-re flake (a FreeImageRe build dependency, absent from nixpkgs).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-lib = {
      url = "github:jgus-org/flake-lib/v1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      flake-lib,
    }:
    let
      pin = import ./pin.nix;
      # No releases; tracks a commit. Bump to the revision FreeImageRe expects: nix run .#update-version -- <rev>
      source = {
        type = "github";
        owner = "agruzdev";
        repo = "Yato";
        track = "commit";
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        };
        yato-src = pkgs.fetchFromGitHub {
          inherit (source) owner repo;
          rev = pin.sourceRev;
          hash = pin.sourceHash;
        };
      in
      {
        packages = {
          inherit yato-src;
          default = yato-src;
          update-version = flake-lib.lib.mkUpdateVersion {
            inherit pkgs source;
            buildAttr = "yato-src";
          };
        };

        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;
      }
    );
}
