defmodule Cortex.Worker.Supervisor do
  @moduledoc """
  Keeps serial devices running
  """

  use Supervisor


  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # based on ecto results
    # lets say it gives us
    # produce list of children from that...
    #children = things |> Enum.map(fn (thing) -> 
    #  worker(Cortex.Worker.Interface, [thing.firmware_name])
    #  {}
    #end)


    supervise([], strategy: :one_for_one)
  end
end
