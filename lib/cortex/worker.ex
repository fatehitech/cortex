defmodule Cortex.Worker do
  use GenServer
  alias Cortex.Worker, as: Worker

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :cortex_worker)
  end

  def init(:ok) do
    Worker.Mapper.start_link
  end
end
