defmodule Michel.Stats.Projections.FeedVisit do
  use Ecto.Schema

  schema "feed_visits" do
    field(:feed_id, :string)
    field(:type, :string)
    field(:date, :date)
    field(:count, :integer)

    timestamps()
  end
end
