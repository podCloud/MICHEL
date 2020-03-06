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
  alias __MODULE__

  def execute(%View{id: nil}, %VisitFeed{} = command) do
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
end
