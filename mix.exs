defmodule DiscordWebhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_webhook,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mimerl, "~> 1.0"},
      {:req, "~> 0.5"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev], runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test], runtome: false}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md"
      ],
      main: "readme",
      groups_for_docs: [
        Guards: &(&1[:guard] == true)
      ]
    ]
  end
end
