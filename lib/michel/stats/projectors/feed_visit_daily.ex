defmodule Michel.Stats.Projectors.FeedVisitDaily do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "Stats.Projectors.FeedVisitDaily",
    consistency: :strong

  alias Michel.Repo
  alias Michel.Stats.Events.FeedVisited
  alias Michel.Stats.Projections.FeedVisit

  project(%FeedVisited{} = event, _metadata, fn multi ->
    date = event.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()

    case Repo.get_by(FeedVisit, feed_id: event.feed_id, date: date, type: "daily") do
      nil ->
        Ecto.Multi.insert(multi, :feed_visits, %FeedVisit{
          feed_id: event.feed_id,
          type: "daily",
          date: date,
          count: 1
        })

      visit ->
        Ecto.Multi.update(
          multi,
          :feed_visits,
          Ecto.Changeset.change(visit, count: visit.count + 1)
        )
    end
  end)
end
