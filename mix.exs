defmodule Lintron.Mixfile do
  use Mix.Project

  def project do
    [
      app: :lintron,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8.8"},
    ]
  end
end
