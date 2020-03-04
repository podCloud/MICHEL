defmodule MichelWeb.Router do
  use MichelWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MichelWeb do
    pipe_through :api
  end
end
