defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitterWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/followers" ,TwitterController , :followers
    get "/discover" ,TwitterController , :discover
    get "/tweets" ,TwitterController , :tweets
    post "/tweet/new" ,TwitterController, :new_tweet
    post "/follow" ,TwitterController, :follow
    post "/unfollow" ,TwitterController, :unfollow
    get "/login" ,TwitterController, :login
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end
end
