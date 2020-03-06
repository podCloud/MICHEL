defmodule Michel.Factory do
  use ExMachina

  alias Michel.View.Commands.VisitFeed
  alias Michel.View.Events.FeedVisited

  def view_factory do
    %{
      id: UUID.uuid4()
    }
  end

  def visit_feed_factory do
    struct(VisitFeed, build(:view))
  end

  def feed_visited_factory do
    struct(FeedVisited, build(:view))
  end
end
