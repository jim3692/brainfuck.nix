{
 inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      getApp = script:
        let
          run = pkgs.writeShellApplication {
            name = "run";
            text = script;
          };
        in {
          type = "app";
          program = "${run}/bin/run";
        };

      io = import ./io pkgs;

      runtimes = {
        brainfuck = import ./brainfuck.nix pkgs.lib;
        i-use-arch-btw = import ./i-use-arch-btw.nix pkgs.lib;
      };
    in {
      apps.${system} = rec {
        hello-world =
          let
            code = builtins.readFile ./examples/hello-world.bf;
            inherit (runtimes.brainfuck { inherit code; }) output;
            resultsFile = builtins.toFile "result" (io.bytesToText output);
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        multiplication =
          let
            INPUT = "56"; # 5 * 6
            code = builtins.readFile ./examples/multiplication.bf;
            inherit (runtimes.brainfuck { inherit code; input = io.textToBytes INPUT; }) output;
            resultsFile = builtins.toFile "result" (toString output); # the result is an 8-bit int, not a string
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        echo =
          let
            INPUT = "Hello World!";
            code = builtins.readFile ./examples/echo.bf;
            result = runtimes.brainfuck { inherit code; input = (io.textToBytes INPUT) ++ [ 0 ]; }; # Loop until \0
            inherit (result) output;
            resultsFile = builtins.toFile "result" (io.bytesToText output);
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        default = hello-world;

        i-use-arch-btw =
          let
            code = builtins.readFile ./examples/hello-world.archbtw;
            inherit (runtimes.i-use-arch-btw { inherit code; }) output;
            resultsFile = builtins.toFile "result" (io.bytesToText output);
          in getApp ''
            cat ${resultsFile} ; echo
          '';
      };
    };
}
