# Used by "mix format"
[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [allow: :*, expect: :*, matcher: :*, assert_called: :*, refute_called: :*],
  line_length: 120,
  export: [
    locals_without_parens: [allow: :*, expect: :*, assert_called: :*, refute_called: :*]
  ]
]
