defmodule Cortex.Repo.Migrations.AddSeriesCodeToThing do
  use Ecto.Migration

  def up do
    alter table(:things) do
      add :series_code, :text
    end
  end

  def down do
    alter table(:things) do
      remove :series_code
    end
  end
end
