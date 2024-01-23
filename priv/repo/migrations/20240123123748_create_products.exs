defmodule Fms.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :text
      add :price, :decimal
      add :stock_quantity, :integer
      add :available, :boolean, default: true, null: false
      add :product_category_id, references(:product_categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:products, [:product_category_id])
  end
end
