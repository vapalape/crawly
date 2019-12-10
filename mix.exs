defmodule Crawly.Mixfile do
  use Mix.Project

  @version "0.7.0-dev"

  def project do
    [
      app: :crawly,
      version: @version,
      name: "Crawly",
      source_url: "https://github.com/oltarasenko/crawly",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      elixirc_options: [warnings_as_errors: true],
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :sasl, :httpoison],
      mod: {Crawly.Application, []}
    ]
  end

  defp description() do
    "high-level web crawling & scraping framework for Elixir."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "crawly",
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/oltarasenko/crawly",
        "Docs" => "https://oltarasenko.github.io/crawly/"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:new_gollum, "~> 0.3.0"},
      {:plug_cowboy, "~> 2.0"},
      {:epipe, "~> 1.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:meck, "~> 0.8.13", only: :test},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      logo: "documentation/assets/logo.png",
      extra_section: "documentation",
      main: "quickstart",
      #      assets: "guides/assets",
      formatters: ["html"],
      groups_for_modules: [
        "Engine Level": [Crawly, Crawly.Engine, Crawly.EngineSup],
        "Spider Management Level": [
          Crawly.Manager,
          Crawly.ManagerSup,
          Crawly.Worker,
          Crawly.DataStorage,
          Crawly.DataStorage.Worker,
          Crawly.RequestsStorage,
          Crawly.RequestsStorage.Worker
        ],
        "Requests and Responses": [
          Crawly.Response,
          Crawly.Request
        ],
        "Middlewares and Pipelines": ~r"Crawly\.(Pipeline|Middlewares)(.*)",
        "Spider Implementation": [
          Crawly.Spider,
          Crawly.ParsedItem
        ],
        "HTTP API": [Crawly.API.Router],
        Utility: [Crawly.Utils]
      ],
      extras: extras()
      #      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "documentation/quickstart.md",
      "documentation/introduction.md",
      "documentation/ethical_aspects.md",
      "documentation/installation_guide.md",
      "documentation/tutorial.md",
      "documentation/basic_concepts.md",
      "documentation/settings.md",
      "documentation/http_api.md"
    ]
  end
end
