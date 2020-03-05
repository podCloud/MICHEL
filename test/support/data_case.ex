defmodule Michel.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Michel.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Michel.Factory
      import Michel.DataCase
    end
  end

  setup do
    Michel.Storage.reset!()
    :ok
  end
end
