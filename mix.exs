defmodule PhoenixPubsubPartisan.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_pubsub_partisan,
      description: "Phoenix pubsub using Partisan",
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: [
        main: "Phoenix.Pubsub.Partisan",
        source_ref: "main"
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Razvan Draghici"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/tzumby/phoenix_pubsub_partisan"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.0"},
      {:partisan, git: "https://github.com/lasp-lang/partisan.git"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
