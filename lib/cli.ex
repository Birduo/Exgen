defmodule Exgen.CLI do
  @moduledoc """
  Command line interface for Exgen.

  Exgen/Hgen usage: exgen/hgen <input.md> <output.html> [header.html]
  """
  def main(args) do
    case length(args) do
      0 ->
        IO.puts "Usage: exgen/hgen <input.md> [output.html] [header.html]"
        System.halt(1)

      1 ->
        in_md = Enum.at(args, 0)
        basename = Path.basename(in_md, ".md")

        {:ok, file_data} = File.read(in_md)
        # ast -> html (returns as an html string)
        html = Exgen.as_ast(file_data) |> Earmark.transform()
        # write html to file
        File.write("#{basename}.html", html)

      2 ->
        in_md = Enum.at(args, 0)
        out_html = Enum.at(args, 1)

        {:ok, file_data} = File.read(in_md)
        html = Exgen.as_ast(file_data) |> Earmark.transform()

        File.write(out_html, html)
      3 ->
        in_md = Enum.at(args, 0)
        out_html = Enum.at(args, 1)
        header_html = Enum.at(args, 2)

        {:ok, file_data} = File.read(in_md)
        {:ok, header} = File.read(header_html)

        html = Exgen.as_ast(file_data) |> Earmark.transform()

        File.write(out_html, header <> html)
    end
  end
end
