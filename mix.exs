defmodule SkyFraud.MixProject do
  use Mix.Project

  def project do
    [
      app: :sky_fraud,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: [],
      escript: [main_module: SkyFraud.CLI]
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
