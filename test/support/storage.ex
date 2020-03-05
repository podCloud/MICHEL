defmodule Michel.Storage do
  @doc """
  Reset the event store and read store databases.
  """
  def reset! do
    :ok = Application.stop(:michel)

    reset_eventstore!()

    {:ok, _} = Application.ensure_all_started(:michel)
  end

  defp reset_eventstore! do
    {:ok, conn} =
      Michel.EventStore.config()
      |> EventStore.Config.default_postgrex_opts()
      |> Postgrex.start_link()

    EventStore.Storage.Initializer.reset!(conn)
  end
end
