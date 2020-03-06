defmodule Michel.Repo.Migrations.UniqueVisit do
  use Ecto.Migration

  def change do
    create table(:unique_visits, primary_key: false) do
      add(:track_id, :string, primary_key: true)
      add(:created_at, :naive_datetime)

      timestamps(type: :naive_datetime_usec)
    end
  end
end
