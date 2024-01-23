defmodule FmsWeb.ProductCategoryLive.FormComponent do
  use FmsWeb, :live_component

  alias Fms.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product_category records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product_category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="row">
          <div class="col col-sm-12 col-md-6">
            <.input field={@form[:name]} type="text" label="Name" />
          </div>
          <div class="col col-sm-12 col-md-6">
            <.input field={@form[:description]} type="textarea" label="Description" />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Product category</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product_category: product_category} = assigns, socket) do
    changeset = Products.change_product_category(product_category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product_category" => product_category_params}, socket) do
    changeset =
      socket.assigns.product_category
      |> Products.change_product_category(product_category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product_category" => product_category_params}, socket) do
    save_product_category(socket, socket.assigns.action, product_category_params)
  end

  defp save_product_category(socket, :edit, product_category_params) do
    case Products.update_product_category(socket.assigns.product_category, product_category_params) do
      {:ok, product_category} ->
        notify_parent({:saved, product_category})

        {:noreply,
         socket
         |> put_flash(:info, "Product category updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product_category(socket, :new, product_category_params) do
    case Products.create_product_category(product_category_params) do
      {:ok, product_category} ->
        notify_parent({:saved, product_category})

        {:noreply,
         socket
         |> put_flash(:info, "Product category created successfully")
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
