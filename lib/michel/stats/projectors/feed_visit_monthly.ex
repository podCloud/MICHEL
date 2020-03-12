defmodule Michel.Stats.Projectors.FeedVisitMonthly do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "Stats.Projectors.FeedVisitMonthly",
    consistency: :strong

  alias Michel.Repo
  alias Michel.Stats.Events.FeedVisited
  alias Michel.Stats.Projections.FeedVisit

  project(%FeedVisited{} = event, _metadata, fn multi ->
    date = event.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()
    first_day_of_month = %{date | day: 1}

    case Repo.get_by(FeedVisit, feed_id: event.feed_id, date: first_day_of_month, type: "monthly") do
      nil ->
        Ecto.Multi.insert(multi, :feed_visits, %FeedVisit{
          feed_id: event.feed_id,
          type: "monthly",
          date: first_day_of_month,
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
