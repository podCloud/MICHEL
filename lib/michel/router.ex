defmodule Michel.Router do
  use Commanded.Commands.Router
  alias Michel.View.Aggregates.View
  alias Michel.View.Commands.VisitFeed

  dispatch(VisitFeed, to: View, identity: :id)
end
