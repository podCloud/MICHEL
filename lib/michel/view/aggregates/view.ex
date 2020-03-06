defmodule Michel.View.Aggregates.View do
  defstruct [
    :id,
    :track_id,
    :feed_id,
    :user_agent,
    :referer,
    :country,
    :region,
    :city,
    :created_at
  ]

  alias Michel.View.Commands.VisitFeed
  alias Michel.View.Events.FeedVisited
  alias Michel.View.Projections.UniqueVisit
  alias Michel.Repo
  alias __MODULE__

  def execute(%View{id: nil}, %VisitFeed{} = command) do
    datetime =
      command.created_at |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.truncate(:second)

    case Repo.get(UniqueVisit, command.track_id) do
      nil ->
        make_feed_visited(%VisitFeed{command | created_at: datetime})

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
            make_feed_visited(%VisitFeed{command | created_at: datetime})
        end
    end
  end

  def apply(%View{}, %FeedVisited{} = event) do
    %View{
      id: event.id,
      track_id: event.track_id,
      feed_id: event.feed_id,
      user_agent: event.user_agent,
      referer: event.referer,
      country: event.country,
      region: event.region,
      city: event.city,
      created_at: event.created_at
    }
  end

  defp make_feed_visited(command) do
    %FeedVisited{
      id: command.id,
      track_id: command.track_id,
      feed_id: command.feed_id,
      user_agent: command.user_agent,
      referer: command.referer,
      country: command.country,
      region: command.region,
      city: command.city,
      created_at: command.created_at
    }
  end
end
