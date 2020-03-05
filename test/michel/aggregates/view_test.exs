defmodule Michel.Aggregates.ViewTest do
  use Michel.DataCase
  import Commanded.Assertions.EventAssertions

  alias Michel.View.VisitFeed
  alias Michel.View.FeedVisited

  test "should succeed when valid" do
    id = UUID.uuid4()

    :ok = Michel.Commanded.dispatch(%VisitFeed{id: id})

    assert_receive_event(Michel.Commanded, FeedVisited, fn event ->
      assert event.id == id
    end)
  end
end
