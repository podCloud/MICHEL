defmodule Michel.Stats.Projections.EnclosureDownload do
  use Ecto.Schema

  schema "enclosure_downloads" do
    field(:feed_id, :string)
    field(:item_id, :string)
    field(:type, :string)
    field(:date, :date)
    field(:source, :string)
    field(:count, :integer)

    timestamps()
  end
end
