defmodule FmsWeb.DashboardLive.Index do
  use FmsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :active_link, :dashboard)}
  end
end
