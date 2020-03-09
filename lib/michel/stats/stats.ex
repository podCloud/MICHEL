defmodule Michel.Stats do
  alias Michel.Commanded
  alias Michel.Repo
  alias Michel.Stats.Commands.{VisitFeed, DownloadEnclosure}
  alias Michel.Stats.Projections.{UniqueVisit, UniqueDownload}

  def visit_feed(attrs) do
    command = %VisitFeed{
      id: attrs.id,
      track_id: attrs.track_id,
      feed_id: attrs.feed_id,
      user_agent: attrs.user_agent,
      referer: attrs.referer,
      country: attrs.country,
      region: attrs.region,
      city: attrs.city,
      created_at: attrs.created_at
    }

    with :ok <- Commanded.dispatch(command, consistency: :strong) do
      get(UniqueVisit, attrs.track_id)
    else
      reply -> reply
    end
  end

  def download_enclosure(attrs) do
    command = %DownloadEnclosure{
      id: attrs.id,
      track_id: attrs.track_id,
      feed_id: attrs.feed_id,
      item_id: attrs.item_id,
      source: attrs.source,
      user_agent: attrs.user_agent,
      referer: attrs.referer,
      country: attrs.country,
      region: attrs.region,
      city: attrs.city,
      created_at: attrs.created_at
    }

    with :ok <- Commanded.dispatch(command, consistency: :strong) do
      get(UniqueDownload, attrs.track_id)
    else
      reply -> reply
    end
  end

  defp get(schema, id) do
    case Repo.get(schema, id) do
      nil -> {:error, :not_found}
      projection -> {:ok, projection}
    end
  end
end
