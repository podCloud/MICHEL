defmodule Michel.Router do
  use Commanded.Commands.Router
  alias Michel.Stats.Aggregates.View
  alias Michel.Stats.Commands.VisitFeed

  dispatch(VisitFeed, to: View, identity: :id)
end
