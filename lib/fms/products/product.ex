defmodule Fms.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :available, :boolean, default: true
    field :price, :decimal
    field :stock_quantity, :integer
    belongs_to :product_category, Fms.Products.ProductCategory

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :stock_quantity, :available, :product_category_id])
    |> validate_required([:name, :price, :stock_quantity, :product_category_id])
  end
end
