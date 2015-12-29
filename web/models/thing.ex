defmodule Cortex.Thing do
  use Cortex.Web, :model

  @default_code String.strip ~S"""
  # This example blinks pin 13

  # This function is the entry point
  def handle_info({:firmata, {:pin_map, _pin_map}}, {board, serial}) do
    Board.set_pin_mode(board, 13, @output)
    pid = self()
    spawn_link(fn-> blink(pid) end)
    {:noreply, {board, serial, @low}}
  end

  # Our blink loop
  def blink(pid) do
    send(pid, :blink)
    :timer.sleep 1_000
    blink(pid)
  end

  # When pin 13 is high, set it low
  def handle_info(:blink, {board, serial, @high}) do
    Board.digital_write(board, 13, @low)
    {:noreply, {board, serial, @low}}
  end

  # When pin 13 is low, set it high
  def handle_info(:blink, {board, serial, @low}) do
    Board.digital_write(board, 13, @high)
    {:noreply, {board, serial, @high}}
  end
  """

  schema "things" do
    field :firmware_name, :string
    field :code, :string, default: @default_code

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
end
