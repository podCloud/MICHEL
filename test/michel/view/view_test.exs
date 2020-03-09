defmodule Michel.View.ViewTest do
  use Michel.DataCase

  alias Michel.View
  alias Michel.View.Projections.UniqueVisit

  test "should create unique visit if none exists for a given track_id" do
    track_id = UUID.uuid4()

    assert {:ok, %UniqueVisit{} = visit} = View.visit_feed(build(:view, track_id: track_id))
    assert visit.track_id == track_id
  end

  test "should not update visit if same track_id in less than 24h interval" do
    track_id = UUID.uuid4()

    View.visit_feed(build(:view, track_id: track_id, created_at: "2020-03-06T17:00:00.45"))

    assert {:ok, %UniqueVisit{} = visit} =
             View.visit_feed(
               build(:view, track_id: track_id, created_at: "2020-03-07T16:59:59.45")
             )

    assert visit.track_id == track_id
    assert visit.created_at == ~N[2020-03-06 17:00:00]
  end

  test "should update visit if same track_id in a 24h interval or more" do
    track_id = UUID.uuid4()

    View.visit_feed(build(:view, track_id: track_id, created_at: "2020-03-06T17:00:00.45"))

    assert {:ok, %UniqueVisit{} = visit} =
             View.visit_feed(
               build(:view, track_id: track_id, created_at: "2020-03-07T17:00:00.45")
             )

    assert visit.track_id == track_id
    assert visit.created_at == ~N[2020-03-07 17:00:00]
  end
end
