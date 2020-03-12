defmodule Michel.Repo.Migrations.CreateFeedVisits do
  use Ecto.Migration

  def change do
    create table(:feed_visits) do
      add(:feed_id, :string)
      add(:type, :string)
      add(:date, :date)
      add(:count, :integer)

      timestamps(type: :naive_datetime_usec)
    end
  end
end
