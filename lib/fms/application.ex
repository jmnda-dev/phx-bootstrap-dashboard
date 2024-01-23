defmodule Fms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FmsWeb.Telemetry,
      # Start the Ecto repository
      Fms.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fms.PubSub},
      # Start Finch
      {Finch, name: Fms.Finch},
      # Start the Endpoint (http/https)
      FmsWeb.Endpoint
      # Start a worker by calling: Fms.Worker.start_link(arg)
      # {Fms.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
