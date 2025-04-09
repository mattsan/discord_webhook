defmodule DiscordWebhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_webhook,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:dialyxir, "~> 1.0", only: [:dev]},
      {:credo, "~> 1.0", only: [:dev]},
      {:ex_doc, "~> 0.37", only: [:dev]},
      {:igniter, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
