# Exgen

## Exgen - Elixir HGen successor
Exgen parses markdown and transforms it into interactive HTML!
I used to create the parse tree with **hgen**, however why re-invent the wheel when going for pro?

### Features
- `js` code blocks become embedded as `<script>` tags
- `javascript` code blocks remain as code blocks
- `::<name>` becomes a `canvas` tag with `id=<name>`
- `<a>` tags, if `css` or `js` will directly add the associated css/js code


## Examples

```elixir
  iex> [ "```js", "console.log('test')", "```" ] |> Exgen.as_ast()
  [{"script", [], ["console.log('test')"], %{verbatim: true}}]

  iex> [ "::name" ] |> Exgen.as_ast()
  [{"canvas", [{"id", "name"}], [], %{}}]


  iex> [ "<a href='script.js'>js link</a>" ] |> Exgen.as_ast()
  [{"a", [{"href", "script.js"}], [["js link"], {"script", [{"src", "script.js"}], [], %{verbatim: true}}], %{verbatim: true}}]

  iex> [ "<a href='style.css'>css link</a>" ] |> Exgen.as_ast()
  [{"a", [{"href", "style.css"}], [["css link"], {"link", [{"rel", "stylesheet"}, {"href", "style.css"}], [], %{verbatim: true}}], %{verbatim: true}}]

  iex> Exgen.parse_file("test.md")
  :ok
```

### Dependencies
- earmark-parser
- earmark

### Building
`mix deps.get && MIX_ENV=prod mix escript.build`

### Running from CLI
`Usage: exgen/hgen <input.md> [output.html] [header.html]`

### How is it done?
**exgen** uses [earmark transforms](https://hexdocs.pm/earmark/Earmark.Transform.html) to transform the AST generated

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exgen` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exgen, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/exgen>.

