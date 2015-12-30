defmodule Cortex.Thing do
  use Cortex.Web, :model

  schema "things" do
    field :firmware_name, :string
    field :code, :string

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
    code = Cortex.Repo.one(from thing in Cortex.Thing, select: thing.code, where: thing.firmware_name == ^name)
    if code do
      {:ok, code}
    else
      {:error}
    end
  end

  @doc """
  Thalamex can publish messages to Cortex, which will come through in this method.
  If there is going to be some kind of pub sub routing I suppose this is the data entrypoint
  """
  def handle_in(name, data) do
    IO.inspect data
    :ok
  end
end
