defmodule Fms.ProductsTest do
  use Fms.DataCase

  alias Fms.Products

  describe "product_categories" do
    alias Fms.Products.ProductCategory

    import Fms.ProductsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_product_categories/0 returns all product_categories" do
      product_category = product_category_fixture()
      assert Products.list_product_categories() == [product_category]
    end

    test "get_product_category!/1 returns the product_category with given id" do
      product_category = product_category_fixture()
      assert Products.get_product_category!(product_category.id) == product_category
    end

    test "create_product_category/1 with valid data creates a product_category" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %ProductCategory{} = product_category} = Products.create_product_category(valid_attrs)
      assert product_category.name == "some name"
      assert product_category.description == "some description"
    end

    test "create_product_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product_category(@invalid_attrs)
    end

    test "update_product_category/2 with valid data updates the product_category" do
      product_category = product_category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %ProductCategory{} = product_category} = Products.update_product_category(product_category, update_attrs)
      assert product_category.name == "some updated name"
      assert product_category.description == "some updated description"
    end

    test "update_product_category/2 with invalid data returns error changeset" do
      product_category = product_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product_category(product_category, @invalid_attrs)
      assert product_category == Products.get_product_category!(product_category.id)
    end

    test "delete_product_category/1 deletes the product_category" do
      product_category = product_category_fixture()
      assert {:ok, %ProductCategory{}} = Products.delete_product_category(product_category)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product_category!(product_category.id) end
    end

    test "change_product_category/1 returns a product_category changeset" do
      product_category = product_category_fixture()
      assert %Ecto.Changeset{} = Products.change_product_category(product_category)
    end
  end

  describe "products" do
    alias Fms.Products.Product

    import Fms.ProductsFixtures

    @invalid_attrs %{name: nil, description: nil, available: nil, price: nil, stock_quantity: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", description: "some description", available: true, price: "120.5", stock_quantity: 42}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.description == "some description"
      assert product.available == true
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", available: false, price: "456.7", stock_quantity: 43}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.description == "some updated description"
      assert product.available == false
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
