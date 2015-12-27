defmodule Cortex.Repo.Migrations.CreateThing do
  use Ecto.Migration

  def change do
    create table(:things) do
      add :firmware_name, :string
      add :code, :text

      timestamps
    end

  end
end
