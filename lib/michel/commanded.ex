defmodule Michel.Commanded do
  use Commanded.Application,
    otp_app: :michel,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Michel.EventStore
    ]

  router(Michel.Router)
end
