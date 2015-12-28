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
    #devices = devices |> find_and_update_by_tty(tty, fn(dev)->
    #  code = Cortex.Repo.one(from thing in Cortex.Thing, select: thing.code, where: thing.firmware_name == ^name)
    #  if code do
    #    module = Cortex.ThingCode.to_module(code, name)
    #    {:ok, pid} = module.start_link(tty, @baudrate)
    #    dev = Keyword.put(dev, :pid, pid)
    #  else
    #    dev
    #  end
    #  Keyword.put(dev, :name, name)
    #end)
    {:noreply, devices}
  end

end
