defmodule Michel.View.Projectors.UniqueVisit do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "View.Projectors.UniqueVisit",
    consistency: :strong

  alias Michel.View.Events.FeedVisited
  alias Michel.View.Projections.UniqueVisit

  project(%FeedVisited{} = visit, _metadata, fn multi ->
    datetime = NaiveDateTime.from_iso8601!(visit.created_at)

    Ecto.Multi.insert(multi, :unique_visits, %UniqueVisit{
      track_id: visit.track_id,
      created_at: NaiveDateTime.truncate(datetime, :second)
    })
  end)
end
