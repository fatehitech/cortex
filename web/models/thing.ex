defmodule Cortex.Thing do
  use Cortex.Web, :model

  schema "things" do
    field :firmware_name, :string
    field :code, :string
    field :series_code, :string

    timestamps
  end

  @required_fields ~w(firmware_name code)
  @optional_fields ~w(series_code)

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
    thing = Cortex.Repo.one(from thing in Cortex.Thing, where: thing.firmware_name == ^name)
    if thing do
      structs =
        thing
        |> Map.fetch!(:series_code)
        |> Code.compile_string()

      Enum.each(structs, fn(struct) ->
        struct = struct |> elem(0)
        try do
          db = struct.__meta__(:database)
          db
          |> Instream.Cluster.Database.create([ if_not_exists: true ])
          |> Cortex.InstreamConnection.execute()
          IO.puts "created db #{db}"
        rescue
          _ -> nil
        end
      end)

      {:ok, Map.fetch!(thing, :code)}
    else
      {:error}
    end
  end

  def call_thing(name, message) do
    rpc(:call_thing, [name, message])
  end

  def send_message(name, message) do
    rpc(:send_thing, [name, message])
  end

  def reset(name) do
    rpc(:reset_thing, [name])
  end

  defp rpc(manager_func, args) do
    Node.list() |> Enum.map(fn(n) ->
      res = :rpc.call(n, Axon.Thing.Manager, manager_func, args)
      case res do
        {:badrpc, _} -> nil
        _ -> res
      end
    end)
    |> Enum.reject(fn(res) -> res == nil end)
    |> List.last
  end

  def handle_in(_name, {:write_series, struct_mod, map}) do
    data = struct_mod |> struct()
    fields_mod = Atom.to_string(struct_mod)<>".Fields" |> String.to_atom()
    tags_mod = Atom.to_string(struct_mod)<>".Tags" |> String.to_atom()
    data = %{ data | fields: struct(fields_mod, Map.get(map, :fields) || %{}) }
    data = %{ data | tags: struct(tags_mod, Map.get(map, :tags) || %{}) }
    Cortex.InstreamConnection.write(data)
  end

  @doc """
  Axon can publish messages to Cortex, which will come through in this method.
  If there is going to be some kind of pub sub routing I suppose this is the data entrypoint
  """
  def handle_in(name, data) do
    IO.inspect data
    :ok
  end
end
