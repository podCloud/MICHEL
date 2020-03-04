defmodule Michel.Router do
  use Commanded.Commands.Router
  alias Michel.View
  alias Michel.View.VisitFeed

  dispatch(VisitFeed, to: View, identity: :id)
end
