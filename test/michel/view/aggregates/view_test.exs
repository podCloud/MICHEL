defmodule Michel.View.Aggregates.ViewTest do
  use Michel.DataCase
  import Commanded.Assertions.EventAssertions
  alias Michel.View.Events.FeedVisited

  test "should emit an event when valid" do
    id = UUID.uuid4()

    Michel.Commanded.dispatch(build(:visit_feed, id: id))

    assert_receive_event(Michel.Commanded, FeedVisited, fn event ->
      assert event.id == id
    end)
  end

  test "should not emit an event when same track_id is used twice in a 24h interval" do
    track_id = UUID.uuid4()

    Michel.Commanded.dispatch(
      build(:visit_feed, track_id: track_id, created_at: "2020-03-06T17:00:00.45")
    )

    Michel.Commanded.dispatch(
      build(:visit_feed, track_id: track_id, created_at: "2020-03-07T16:59:59.45")
    )

    assert_receive_event(
      Michel.Commanded,
      FeedVisited,
      fn event ->
        event.created_at == "2020-03-06T17:00:00"
      end,
      fn event ->
        assert event.track_id == track_id
      end
    )

    refute_receive_event(Michel.Commanded, FeedVisited,
      predicate: fn event -> event.created_at == "2020-03-06T16:59:59.45" end
    ) do
    end
  end

  test "should emit an event when same track_id is used twice but with a 24h or more interval" do
    track_id = UUID.uuid4()

    Michel.Commanded.dispatch(
      build(:visit_feed, track_id: track_id, created_at: "2020-03-06T17:00:00.45")
    )

    Michel.Commanded.dispatch(
      build(:visit_feed, track_id: track_id, created_at: "2020-03-07T17:00:00.45")
    )

    assert_receive_event(
      Michel.Commanded,
      FeedVisited,
      fn event ->
        event.created_at == "2020-03-06T17:00:00"
      end,
      fn event ->
        assert event.track_id == track_id
      end
    )

    assert_receive_event(
      Michel.Commanded,
      FeedVisited,
      fn event ->
        event.created_at == "2020-03-07T17:00:00"
      end,
      fn event ->
        assert event.track_id == track_id
      end
    )
  end
end
