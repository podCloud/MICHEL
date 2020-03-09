defmodule Michel.View.Projectors.UniqueVisit do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "View.Projectors.UniqueVisit",
    consistency: :strong

  alias Michel.Repo
  alias Michel.View.Events.FeedVisited
  alias Michel.View.Projections.UniqueVisit

  project(%FeedVisited{track_id: track_id, created_at: created_at}, _metadata, fn multi ->
    datetime = created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.truncate(:second)

    case Repo.get(UniqueVisit, track_id) do
      nil ->
        Ecto.Multi.insert(multi, :unique_visits, %UniqueVisit{
          track_id: track_id,
          created_at: datetime
        })

      visit ->
        case(NaiveDateTime.compare(NaiveDateTime.add(visit.created_at, 86400), datetime)) do
          :gt ->
            multi

          _ ->
            Ecto.Multi.update(
              multi,
              :unique_visits,
              Ecto.Changeset.change(visit, created_at: datetime)
            )
        end
    end
  end)
end
