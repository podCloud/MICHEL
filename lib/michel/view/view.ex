defmodule Michel.View do
  alias Michel.Commanded
  alias Michel.Repo
  alias Michel.View.Commands.VisitFeed
  alias Michel.View.Projections.UniqueVisit

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

  defp get(schema, id) do
    case Repo.get(schema, id) do
      nil -> {:error, :not_found}
      projection -> {:ok, projection}
    end
  end
end
