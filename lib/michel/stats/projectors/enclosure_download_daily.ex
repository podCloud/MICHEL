defmodule Michel.Stats.Projectors.EnclosureDownloadDaily do
  use Commanded.Projections.Ecto,
    application: Michel.Commanded,
    repo: Michel.Repo,
    name: "Stats.Projectors.EnclosureDownloadDaily",
    consistency: :strong

  alias Michel.Repo
  alias Michel.Stats.Events.EnclosureDownloaded
  alias Michel.Stats.Projections.EnclosureDownload

  project(%EnclosureDownloaded{} = event, _metadata, fn multi ->
    date = event.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()

    case Repo.get_by(EnclosureDownload,
           item_id: event.item_id,
           source: event.source,
           date: date,
           type: "daily"
         ) do
      nil ->
        Ecto.Multi.insert(multi, :enclosure_downloads, %EnclosureDownload{
          feed_id: event.feed_id,
          item_id: event.item_id,
          type: "daily",
          date: date,
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
