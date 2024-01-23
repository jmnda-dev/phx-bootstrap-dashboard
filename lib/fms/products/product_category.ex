defmodule Fms.Products.ProductCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_categories" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(product_category, attrs) do
    product_category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
