defmodule Cortex.Worker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :cortex_worker)
  end

  def init(:ok) do
    {:ok, manager} = Cortex.Thing.Manager.start_link
    spawn_link(fn ->
      Cortex.Thing.Manager.loop(manager)
    end)
    {:ok, {manager}}
  end
end
