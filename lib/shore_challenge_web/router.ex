defmodule ShoreChallengeWeb.Router do
  use ShoreChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ShoreChallengeWeb do
    pipe_through :api
  end
end
