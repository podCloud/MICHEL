# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :michel,
  ecto_repos: [Michel.Repo]

# Configures the endpoint
config :michel, MichelWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V2+QCO01sH0g0/h2NknJYVkSluAqKqudzICcdyfq8ptl3gwLCOQhZ+gDnfE46umT",
  render_errors: [view: MichelWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Michel.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "I9PbGHEs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
