defmodule Claude.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "@apps",
      config_path: "@config/config.exs",
      version: "0.1.0",
      listeners: [Phoenix.CodeReloader],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Umbrella-wide deps only; app deps live in @apps/*/mix.exs.
  defp deps do
    []
  end

  defp aliases do
    [
      setup: ["deps.get", "do --app web assets.setup", "do --app web assets.build"],
      # test runs in a fresh process with MIX_ENV exported: `preferred_envs` switches
      # Mix.env() only after mix.exs is evaluated, so `elixirc_paths(Mix.env())` resolves
      # against :dev and test/support never compiles for the in-process `test` task.
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --unused",
        "format",
        "cmd env MIX_ENV=test mix test"
      ]
    ]
  end
end
