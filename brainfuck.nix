lib:

{ code
, initialState ? {
    data = { "0" = 0; };
    input = [ ];
    inputPending = false;
    loops = [];
    output = [ ];
    pc = 0;
    ptr = 0;
    zeroFlag = true;
  }
, input ? [ ]
, interactive ? false
}:

let
  inherit (builtins)
    bitAnd
    elemAt
    filter
    foldl'
    hasAttr
    head
    length
    tail
    toString
    ;

  inherit (lib)
    stringToCharacters
    ;

  findFirst = f: list: head (filter f list);

  handleLoopStart = state:
    let
      inherit (findFirst (l: l.start == state.pc) state.loops) end;
    in
      if (state.zeroFlag)
      then { pc = end + 1; }
      else { };

  handleLoopEnd = state:
    let
      inherit (findFirst (l: l.end == state.pc) state.loops) start;
    in
      if (!state.zeroFlag)
      then { pc = start + 1; }
      else { };

  handleInput = state:
    if interactive
    then { inputPending = true; }
    else { data = state.data // { ${toString state.ptr} = head state.input; }; input = tail state.input; };

  lex = {
    ">" = state: { ptr = state.ptr + 1; };
    "<" = state: { ptr = state.ptr - 1; };
    "+" = state: { data = state.data // { ${toString state.ptr} = state.data.${toString state.ptr} + 1; }; };
    "-" = state: { data = state.data // { ${toString state.ptr} = state.data.${toString state.ptr} - 1; }; };
    "[" = state: handleLoopStart state;
    "]" = state: handleLoopEnd state;
    "." = state: { output = state.output ++ [ state.data.${toString state.ptr} ]; };
    "," = state: handleInput state;
  };

  fixData = state:
    let
      tmp = state // {
        data = state.data // (
          if (! hasAttr (toString state.ptr) state.data)
          then { ${toString state.ptr} = 0; }
          else { ${toString state.ptr} = bitAnd 255 state.data.${toString state.ptr}; }
        );
      };
      zeroFlag = tmp.data.${toString tmp.ptr} == 0;
    in tmp // { inherit zeroFlag; };

  parseLoops = tokens:
    let
      result = foldl'
        (data: token: (
          if (token == "[")
          then data // { loops = [ { start = data.idx; } ] ++ data.loops; }
          else if (token == "]")
          then data // {
            loops =
              (filter (l: hasAttr "end" l) data.loops)
              ++ (let
                withoutEnd = filter (l: ! hasAttr "end" l) data.loops;
              in [ { start = (head withoutEnd).start; end = data.idx; } ]
                ++ (tail withoutEnd)
              );
          }
          else data
        ) // { idx = data.idx + 1; })
        { idx = 0; loops = []; }
        tokens;
    in result.loops;

  executeToken = token: state: fixData (state // { pc = state.pc + 1; } // (lex.${token} state));

  executeTokens = { tokens, state }:
    let
      token = elemAt tokens state.pc;
      newState = executeToken token state;
    in
      if newState.inputPending || (newState.pc >= length tokens)
      then newState
      else executeTokens { inherit tokens; state = newState; };

  result =
    let
      tokens = filter (c: hasAttr c lex) (stringToCharacters code);
      state = initialState // { inherit input; loops = parseLoops tokens; };
    in
      executeTokens { inherit tokens state; };

in result
