defmodule FmsWeb.ProductCategoryLive.Index do
  use FmsWeb, :live_view

  alias Fms.Products
  alias Fms.Products.ProductCategory

  @impl true
  def mount(_params, _session, socket) do
    socket =
      stream(socket, :product_categories, Products.list_product_categories())
      |> assign(:active_link, :product_categories)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product category")
    |> assign(:product_category, Products.get_product_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product category")
    |> assign(:product_category, %ProductCategory{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Product categories")
    |> assign(:product_category, nil)
  end

  @impl true
  def handle_info({FmsWeb.ProductCategoryLive.FormComponent, {:saved, product_category}}, socket) do
    {:noreply, stream_insert(socket, :product_categories, product_category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product_category = Products.get_product_category!(id)
    {:ok, _} = Products.delete_product_category(product_category)

    {:noreply, stream_delete(socket, :product_categories, product_category)}
  end
end
