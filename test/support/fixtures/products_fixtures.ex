defmodule Fms.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fms.Products` context.
  """

  @doc """
  Generate a product_category.
  """
  def product_category_fixture(attrs \\ %{}) do
    {:ok, product_category} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description"
      })
      |> Fms.Products.create_product_category()

    product_category
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        available: true,
        price: "120.5",
        stock_quantity: 42
      })
      |> Fms.Products.create_product()

    product
  end
end
