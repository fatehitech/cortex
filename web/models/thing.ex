defmodule Cortex.Thing do
  use Cortex.Web, :model

  schema "things" do
    field :firmware_name, :string
    field :code, :string, default: Cortex.ThingCode.default

    timestamps
  end

  @required_fields ~w(firmware_name code)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def get_code_for(name) do
    Cortex.Repo.one(from thing in Cortex.Thing, select: thing.code, where: thing.firmware_name == ^name)
  end

  def module_name(name) do
    code = get_code_for(name)
    if code do
      Cortex.ThingCode.module_name(name)
      |> String.to_existing_atom()
    else
      nil
    end
  end

  def build_module(name) do
    code = get_code_for(name)
    if code do
      Cortex.ThingCode.to_module(code, name)
    else
      nil
    end
  end
end
