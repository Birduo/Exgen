defmodule ExgenTest do
  use ExUnit.Case
  doctest Exgen

  @doc """
  Markdown to HTML

  parses markdown string with earmark
  transforms the AST with earmark transforms
  returns the html string

  ## Examples

      iex> [ "```js", "console.log('test')", "```" ] |> Exgen.as_ast()
      [{"script", [], ["console.log('test')"], %{verbatim: true}}]

  """
  test "javascript code blocks" do
    js_block = ["```js", "console.log('test')", "```"]
    ast = Exgen.as_ast(js_block)
    assert ast == 
      [{"script", [], ["console.log('test')"], %{verbatim: true}}]
  end
end
