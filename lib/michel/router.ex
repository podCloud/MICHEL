defmodule Michel.Router do
  use Commanded.Commands.Router
  alias Michel.Aggregates.View
  alias Michel.View.Commands.VisitFeed

  dispatch(VisitFeed, to: View, identity: :id)
end
