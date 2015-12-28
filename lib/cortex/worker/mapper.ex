defmodule Cortex.Worker.Mapper do
  use GenServer
  import Ecto.Query

  @baudrate 57600

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :cortex_mapper)
  end

  def init(:ok) do
    state = TtyList.get() |> Enum.map(fn(tty) ->
      {:ok, pid} = Cortex.Worker.ScanApp.start_link(tty, @baudrate)
      [pid: pid, tty: tty, name: nil]
    end)
    {:ok, state}
  end

  def handle_info({:found, tty, name, pid}, devices) do
    IO.puts "found >#{name}<"
    Cortex.Worker.ScanApp.stop(pid)
    {:noreply, devices}
  end

end
