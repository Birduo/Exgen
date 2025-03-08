defmodule Exgen do
  @moduledoc """
  Documentation for `Exgen`.

  ### features
  - `js` code blocks become embedded as `<script>` tags
  - `javascript` code blocks remain as code blocks
  - `::<name>` becomes a `canvas` tag with `id=<name>`
  - `<a>` tags, if `css` or `js` will directly add the css/js code
  - by extension, pure links are no longer allowed
  """

  @doc """
  Markdown to HTML

  parses markdown string with earmark
  transforms the AST with earmark transforms

  ## Examples

      iex> [ "```js", "console.log('test')", "```" ] |> Exgen.as_ast()
      [{"script", [], ["console.log('test')"], %{verbatim: true}}]

      iex> [ "::name" ] |> Exgen.as_ast()
      [{"canvas", [{"id", "name"}], [], %{}}]


      iex> [ "<a href='script.js'>js link</a>" ] |> Exgen.as_ast()
      [{"a", [{"href", "script.js"}], [["js link"], {"script", [{"src", "script.js"}], [], %{verbatim: true}}], %{verbatim: true}}]

      iex> [ "<a href='style.css'>css link</a>" ] |> Exgen.as_ast()
      [{"a", [{"href", "style.css"}], [["css link"], {"link", [{"rel", "stylesheet"}, {"href", "style.css"}], [], %{verbatim: true}}], %{verbatim: true}}]

  """
  def as_ast(md) do
    {:ok, ast, _} = EarmarkParser.as_ast(md, 
      math: true, # latex yippee!
      pure_links: false)

    # `js` code blocks become embedded as `<script>` tags
    # `javascript` code blocks remain as code blocks
    Enum.map(ast, fn
      {"pre", _, [{"code", [{"class", "js"}], [code], _}], _} ->
        {"script", [], [code], %{verbatim: true}}
      {"p", _, ["::" <> name], _} ->
        {"canvas", [{"id", name}], [], %{}}
      {"a", attrs, content, meta} = a_tag ->
        case Enum.find(attrs, fn {k, _} -> k == "href" end) do
          {"href", href} ->
            cond do
              href =~ ~r/\.js$/ -> {
                  "a", attrs, # content below includes script tag prepended with content
                    [content, {"script", [{"src", href}], [], %{verbatim: true}}],
                  meta
              }
              # href =~ ~r/\.js$/ -> {"script", [href], [a_tag], %{verbatim: true}}
              href =~ ~r/\.css$/ -> {
                  "a", attrs, # content below includes style tag prepended with content
                    [content, {"link", [{"rel", "stylesheet"}, {"href", href}], [], %{verbatim: true}}],
                  meta
              }
              # href =~ ~r/\.css$/ -> {"style", [href], [a_tag], %{verbatim: true}}
              true -> a_tag
            end
          _ -> a_tag
        end
      other ->
        other
    end)
  end

  @doc """
  Exgen File

  reads a file and parses it as markdown

  then, returns the markdown as html with the same base filename
  """
  def parse_file(filename) do
    # get basename of filename
    basename = Path.basename(filename, ".md")

    # read file
    {:ok, file_data} = File.read(filename)

    # ast -> html (returns as an html string)
    html = as_ast(file_data) |> Earmark.transform()

    # write html to file
    File.write("#{basename}.html", html)
  end
end
