defmodule Michel.Repo.Migrations.CreateUniqueDownloads do
  use Ecto.Migration

  def change do
    create table(:unique_downloads, primary_key: false) do
      add(:track_id, :string, primary_key: true)
      add(:created_at, :naive_datetime)

      timestamps()
    end
  end
end
