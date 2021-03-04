# General application configuration
use Mix.Config

# Configures the endpoint
config :shore_challenge, ShoreChallengeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sc5iuycNVQf5VRsPKixr4XB0JOdD/AHA80gSbsICqXCFG7BlMXPkN9/8nJH+4v+a",
  render_errors: [view: ShoreChallengeWeb.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
