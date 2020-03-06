defmodule Michel.Factory do
  use ExMachina

  alias Michel.View.Commands.VisitFeed
  alias Michel.View.Events.FeedVisited

  def view_factory do
    %{
      id: UUID.uuid4(),
      track_id: UUID.uuid4(),
      feed_id: UUID.uuid4(),
      user_agent: "iTunes",
      referer: "https://blabla.com/gfdgfdf",
      country: "France",
      region: "Occitanie",
      city: "Toulouse",
      created_at: "2020-03-05T19:20:30.45+01:00"
    }
  end

  def visit_feed_factory do
    struct(VisitFeed, build(:view))
  end

  def feed_visited_factory do
    struct(FeedVisited, build(:view))
  end
end
