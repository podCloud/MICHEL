defmodule Michel.View.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Michel.View.Projectors.UniqueVisit
      ],
      strategy: :one_for_one
    )
  end
end
