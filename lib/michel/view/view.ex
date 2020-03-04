defmodule Michel.View do
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

  alias Michel.View.{FeedVisited, VisitFeed}
  alias __MODULE__

  def execute(%View{id: nil}, %VisitFeed{} = visit) do
    Map.merge(visit, %FeedVisited{})
  end

  def apply(%View{}, %FeedVisited{} = event) do
    Map.merge(event, %View{})
  end
end
