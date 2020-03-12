defmodule Michel.Stats.Projectors.EnclosureDownloadMonthly do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "Stats.Projectors.EnclosureDownloadMonthly",
    consistency: :strong

  alias Michel.Repo
  alias Michel.Stats.Events.EnclosureDownloaded
  alias Michel.Stats.Projections.EnclosureDownload

  project(%EnclosureDownloaded{} = event, _metadata, fn multi ->
    date = event.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()
    first_day_of_month = %{date | day: 1}

    case Repo.get_by(EnclosureDownload,
           item_id: event.item_id,
           source: event.source,
           date: first_day_of_month,
           type: "monthly"
         ) do
      nil ->
        Ecto.Multi.insert(multi, :enclosure_downloads, %EnclosureDownload{
          feed_id: event.feed_id,
          item_id: event.item_id,
          type: "monthly",
          date: first_day_of_month,
          source: event.source,
          count: 1
        })

      visit ->
        Ecto.Multi.update(
          multi,
          :enclosure_downloads,
          Ecto.Changeset.change(visit, count: visit.count + 1)
        )
    end
  end)
end
