use Mix.Config

# Configure your database
config :michel, Michel.Repo,
  username: "postgres",
  password: "postgres",
  database: "michel_test",
  hostname: "localhost",
  pool_size: 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :michel, MichelWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :michel, Michel.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "michel_eventstore_test",
  hostname: "localhost",
  pool_size: 1
