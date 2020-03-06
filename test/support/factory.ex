defmodule Michel.Factory do
  use ExMachina

  alias Michel.View.Commands.VisitFeed
  alias Michel.View.Events.FeedVisited

  def view_factory do
    %{
      id: UUID.uuid4(),
      track_id: "a066be58-96b2-4fc8-9681-cec88df64941",
      feed_id: "fe113110-a5c2-43d7-87bd-472d5e78d460",
      user_agent: "iTunes",
      referer: "https://blabla.com/gfdgfdf",
      country: "France",
      region: "Occitanie",
      city: "Toulouse",
      created_at: "2020-03-05T19:20:30.45+01:00"
    }
  end

  def visit_feed_factory(attrs \\ %{}) do
    struct(VisitFeed, build(:view, attrs))
  end

  def feed_visited_factory(attrs \\ %{}) do
    struct(FeedVisited, build(:view, attrs))
  end
end
