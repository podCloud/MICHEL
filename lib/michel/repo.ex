defmodule Michel.Repo do
  use Ecto.Repo,
    otp_app: :michel,
    adapter: Ecto.Adapters.Postgres
end
