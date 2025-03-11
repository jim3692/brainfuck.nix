lib:

{
  code
, enableGentooInstruction ? false
, ...
}@args:

let
  inherit (builtins)
    concatStringsSep
    filter
    hasAttr
    isString
    length
    map
    split
    stringLength
    throw
    ;

  inherit (lib)
    flatten
    ;

  lex = {
    "i" = ">";
    "use" = "<";
    "arch" = "+";
    "linux" = "-";
    "btw" = ".";
    "by" = ",";
    "the" = "[";
    "way" = "]";
    "gentoo" = "";
  };

  getBfToken = token:
    if (!enableGentooInstruction && token == "gentoo")
    then throw "Instruction 'gentoo' is not enabled!"
    else if (hasAttr token lex)
    then lex.${token}
    else throw "Unexpected token: '${token}'!";

  splitToLines = c:
    let
      allLines = split "\n+" c;
      nonEmptyLines = filter isString allLines;
    in nonEmptyLines;

  clearComments = c:
    let
      lines = splitToLines c;
      parts = map (split "([[:space:]]*;.*$)") lines;
      withoutComments = map (filter (item: (isString item)&& (stringLength item > 0))) parts;
      joined = concatStringsSep "\n" (flatten withoutComments);
    in joined;

  transpileToBf = c:
    let
      tokens = filter isString (split "[[:space:]]" c);
      bfTokens = map getBfToken tokens;
      bf = concatStringsSep "" bfTokens;
    in bf;

  codeWithoutComments = clearComments code;

  bfCode = transpileToBf codeWithoutComments;

  result =
    (import ./brainfuck.nix lib)
    (args // { code = bfCode; });

in result
