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
        Michel.Stats.Projectors.FeedVisit
      ],
      strategy: :one_for_one
    )
  end
end
