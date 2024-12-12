pkgs: rec {
  bytesToTextBin = pkgs.writeCBin "bytesToTextBin" (builtins.readFile ./bytes-to-text.c);
  bytesToText = bytes: with pkgs;
    let
      input = builtins.toFile "input" (lib.concatMapStringsSep "\n" (b: toString b) bytes);
      result = runCommand "bytesToText" { } "(echo '${toString (builtins.length bytes)}' ; cat '${input}') | ${bytesToTextBin}/bin/bytesToTextBin >$out";
    in
      builtins.readFile result;

  textToBytesBin = pkgs.writeCBin "textToBytesBin" (builtins.readFile ./text-to-bytes.c);
  textToBytes = text: with pkgs;
    let
      input = builtins.toFile "input" text;
      result = runCommand "textToBytes" { } "(cat '${input}' ; echo -ne '\\0') | ${textToBytesBin}/bin/textToBytesBin >$out";
      lines = lib.splitString "\n" (builtins.readFile result);
      nonEmptyLines = builtins.filter (l: l != "") lines;
    in
      builtins.map (b: lib.toInt b) nonEmptyLines;
}
