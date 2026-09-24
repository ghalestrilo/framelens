defmodule FramelensWeb.Router do
  use FramelensWeb, :router

  import FramelensWeb.UserAuth
  import Backpex.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FramelensWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FramelensWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", FramelensWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:framelens, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FramelensWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/admin", FramelensWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    backpex_routes()

    live_session :admin,
      on_mount: [
        {FramelensWeb.UserAuth, :require_authenticated},
        {FramelensWeb.UserAuth, :require_admin},
        Backpex.InitAssigns
      ] do
      live_resources "/jobs", Admin.ObanJobLive
      live_resources "/creators", Admin.CreatorLive
      live_resources "/creator_platforms", Admin.CreatorPlatformLive
    end
  end

  ## Authentication routes

  scope "/", FramelensWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FramelensWeb.UserAuth, :require_authenticated}] do
      live "/feed", FeedLive
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      live "/subscriptions", SubscriptionsLive
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", FramelensWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{FramelensWeb.UserAuth, :mount_current_scope}] do
      live "/", LandingLive
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
