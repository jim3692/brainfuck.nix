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

      textToBytes = text: with pkgs; (lib.importJSON (runCommand "textToBytes" { } ''
        ${nodejs}/bin/node -e "console.log(require('fs').readFileSync('${builtins.toFile "input" text}', 'utf8').split('${""}').map(c => c.charCodeAt(0)))" >$out
      '')) ++ [ 0 ];

      bytesToText = bytes: with pkgs; builtins.readFile (runCommand "bytesToText" { } ''
        echo -ne "$(${nodejs}/bin/node -e "console.log(String.fromCharCode(...${builtins.toJSON bytes}))")" >$out
      '');

      brainfuck = import ./brainfuck.nix pkgs.lib;
    in {
      apps.${system} = rec {
        hello-world =
          let
            code = builtins.readFile ./examples/hello-world.bf;
            inherit (brainfuck { inherit code; }) output;
            resultsFile = builtins.toFile "result" (bytesToText output);
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        multiplication =
          let
            INPUT = "56"; # 5 * 6
            code = builtins.readFile ./examples/multiplication.bf;
            inherit (brainfuck { inherit code; input = textToBytes INPUT; }) output;
            resultsFile = builtins.toFile "result" (toString output); # the result is an 8-bit int, not a string
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        echo =
          let
            INPUT = "Hello World!";
            code = builtins.readFile ./examples/echo.bf;
            result = brainfuck { inherit code; input = textToBytes INPUT; };
            inherit (result) output;
            resultsFile = builtins.toFile "result" (bytesToText output);
          in getApp ''
            cat ${resultsFile} ; echo
          '';

        default = hello-world;
      };
    };
}
