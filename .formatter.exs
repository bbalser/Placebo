# Used by "mix format"
[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [allow: :*, expect: :*, matcher: :*],
  line_length: 120,
  export: [
    locals_without_parens: [allow: :*, expect: :*]
  ]
]
