defmodule Michel.Stats.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Michel.Stats.Projectors.UniqueVisit,
        Michel.Stats.Projectors.UniqueDownload,
        Michel.Stats.Projectors.FeedVisitDaily,
        Michel.Stats.Projectors.FeedVisitMonthly,
        Michel.Stats.Projectors.EnclosureDownloadDaily,
        Michel.Stats.Projectors.EnclosureDownloadMonthly
      ],
      strategy: :one_for_one
    )
  end
end
