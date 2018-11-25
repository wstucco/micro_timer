defmodule MicroTimer.MixProject do
  use Mix.Project

  def project do
    [
      app: :micro_timer,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "A timer module with microsend resolution",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:stream_data, "~> 0.4.2", only: :test, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Massimo Ronca"],
      licenses: ["MIT"],
      links: %{
        "GitLab" => "https://gitlab.com/wstucco/micro_timer",
        "GitHub" => "https://github.com/wstucco/micro_timer"
      }
    ]
  end
end
