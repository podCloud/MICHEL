defmodule Michel.View.Projections.UniqueVisit do
  use Ecto.Schema

  @primary_key {:track_id, :string, autogenerate: false}

  schema "unique_visits" do
    field(:created_at, :naive_datetime)

    timestamps()
  end
end
