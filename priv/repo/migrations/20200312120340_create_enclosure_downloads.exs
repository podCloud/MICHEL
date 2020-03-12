defmodule Michel.Repo.Migrations.CreateEnclosureDownloads do
  use Ecto.Migration

  def change do
    create table(:enclosure_downloads) do
      add(:feed_id, :string)
      add(:item_id, :string)
      add(:type, :string)
      add(:date, :date)
      add(:source, :string)
      add(:count, :integer)

      timestamps()
    end
  end
end
