defmodule Michel.Stats.Aggregates.Download do
  defstruct [
    :id,
    :track_id,
    :feed_id,
    :item_id,
    :source,
    :user_agent,
    :referer,
    :country,
    :region,
    :city,
    :created_at
  ]

  alias Michel.Stats.Commands.DownloadEnclosure
  alias Michel.Stats.Events.EnclosureDownloaded
  alias Michel.Stats.Projections.UniqueDownload
  alias Michel.Repo
  alias __MODULE__

  def execute(%Download{id: nil}, %DownloadEnclosure{} = command) do
    datetime =
      command.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.truncate(:second)

    case Repo.get(UniqueDownload, command.track_id) do
      nil ->
        make_enclosure_downloaded(%DownloadEnclosure{command | created_at: datetime})

      visit ->
        case(
          NaiveDateTime.compare(
            NaiveDateTime.add(visit.created_at, 86400),
            datetime
          )
        ) do
          :gt ->
            nil

          _ ->
            make_enclosure_downloaded(%DownloadEnclosure{command | created_at: datetime})
        end
    end
  end

  def apply(%Download{}, %EnclosureDownloaded{} = event) do
    %Download{
      id: event.id,
      track_id: event.track_id,
      feed_id: event.feed_id,
      item_id: event.item_id,
      source: event.source,
      user_agent: event.user_agent,
      referer: event.referer,
      country: event.country,
      region: event.region,
      city: event.city,
      created_at: event.created_at
    }
  end

  defp make_enclosure_downloaded(command) do
    %EnclosureDownloaded{
      id: command.id,
      track_id: command.track_id,
      feed_id: command.feed_id,
      item_id: command.item_id,
      source: command.source,
      user_agent: command.user_agent,
      referer: command.referer,
      country: command.country,
      region: command.region,
      city: command.city,
      created_at: command.created_at
    }
  end
end
