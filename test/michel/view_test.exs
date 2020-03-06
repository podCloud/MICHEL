defmodule Michel.ViewTest do
  use Michel.DataCase

  alias Michel.View
  alias Michel.View.Projections.UniqueVisit

  test "should return unique visit on success" do
    track_id = UUID.uuid4()

    assert {:ok, %UniqueVisit{} = visit} = View.visit_feed(build(:view, track_id: track_id))
    assert visit.track_id == track_id
  end
end
