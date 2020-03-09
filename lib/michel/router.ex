defmodule Michel.Router do
  use Commanded.Commands.Router
  alias Michel.Stats.Aggregates.{View, Download}
  alias Michel.Stats.Commands.{VisitFeed, DownloadEnclosure}

  dispatch(VisitFeed, to: View, identity: :id)
  dispatch(DownloadEnclosure, to: Download, identity: :id)
end
