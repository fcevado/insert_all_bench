defmodule InsertAllBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :insert_all_bench,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {InsertAllBench.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:ecto_sql, github: "ruslandoga/ecto_sql", branch: "alt-insert_all"},
      {:ecto_sql, "~> 3.11.1"},
      {:postgrex, ">= 0.0.0"},
      {:jason, ">= 0.0.0"}
    ]
  end
end
