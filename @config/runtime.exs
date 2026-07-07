import Config

# Executed for all environments at boot (after compilation), so it is the place
# for configuration read from the machine — env vars, secrets.

config :web, Web.Endpoint, http: [port: String.to_integer(System.get_env("PORT", "1024"))]

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :web, Web.Endpoint,
    http: [
      # Loopback only: every route serves ~/.claude contents and mutates it (delete
      # transcripts, rewrite memory, schedule auto-approved `claude` runs) with no
      # authentication. Add an auth layer before ever widening this bind.
      ip: {0, 0, 0, 0, 0, 0, 0, 1}
    ],
    secret_key_base: secret_key_base
end
