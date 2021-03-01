# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :shore_challenge,
  ecto_repos: [ShoreChallenge.Repo]

# Configures the endpoint
config :shore_challenge, ShoreChallengeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sc5iuycNVQf5VRsPKixr4XB0JOdD/AHA80gSbsICqXCFG7BlMXPkN9/8nJH+4v+a",
  render_errors: [view: ShoreChallengeWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ShoreChallenge.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
