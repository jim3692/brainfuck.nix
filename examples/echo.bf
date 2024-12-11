# Arrow
>> ++++ [
  < ++++
  [ < ++++ > - ]
  > -
] << --
>

# Space
>> ++ [
  < ++++
  [ < ++++ > - ]
  > -
] <<
>

# New Line
+++++ +++++
>

# Main loop
+ [

  # Reset main loop flag
  - >

  # Read input
  ,

  # Print formatted input if not \0
  [ <<<< . > . >>> . << . >>

    # Set main loop flag to 1
    < [ - ] + >

    # Clear input
    [ - ]

  ]

  # Point to main loop flag
  <
]
