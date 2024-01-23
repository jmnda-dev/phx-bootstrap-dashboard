defmodule FmsWeb.ProductLive.FormComponent do
  use FmsWeb, :live_component

  alias Fms.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
      <div class="row">
      <div class="col col-sm-12 col-md-6">
        <.input field={@form[:name]} type="text" label="Name" />
        </div>
      <div class="col col-sm-12 col-md-6">
        <.input field={@form[:product_category_id]} type="select" label="Category" options={@product_categories} prompt="Select category" />
        </div>
      <div class="col col-sm-12 col-md-6">
        <.input field={@form[:price]} type="number" label="Price" step="any" />
        </div>
      <div class="col col-sm-12 col-md-6">
        <.input field={@form[:stock_quantity]} type="number" label="Stock quantity" />
        </div>
      <div class="col col-12">
        <.input field={@form[:description]} type="textarea" label="Description" />
        </div>
        </div>
        <.input field={@form[:available]} type="checkbox" label="Available" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Products.change_product(product)
    product_categories =
      Products.list_product_categories()
      |> Enum.map(& {&1.name, &1.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:product_categories, product_categories)
    }
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    case Products.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Products.create_product(product_params) do
      {:ok, product} ->
        product = Fms.Repo.preload(product, :product_category)
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
