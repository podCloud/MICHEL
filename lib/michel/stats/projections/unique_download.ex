defmodule Michel.Stats.Projections.UniqueDownload do
  use Ecto.Schema

  @primary_key {:track_id, :string, autogenerate: false}

  schema "unique_downloads" do
    field(:created_at, :naive_datetime)

    timestamps()
  end
end
