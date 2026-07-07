import Config

config :web, Web.Endpoint,
  # DANGER: bound to all interfaces (0.0.0.0) so other machines on the LAN can POST
  # /feedback. This ALSO exposes every other route — which serves and mutates ~/.claude
  # (deletes transcripts, rewrites memory, schedules auto-approved `claude` runs) with
  # NO authentication. Revert to {127, 0, 0, 1} the moment LAN feedback isn't needed.
  http: [ip: {0, 0, 0, 0}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "RfSxHoe8KymjpCCpNTPWw8m0I7ReTzCGX3iuYwSu/bPIyCKIERPW70qBiGzkgNPU",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:web, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:web, ~w(--watch)]}
  ]

# Reload browser tabs when matching files change.
config :web, Web.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"lib/web/router\.ex$"E,
      ~r"lib/web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

# Enable dev routes (LiveDashboard at /dev/dashboard)
config :web, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true
