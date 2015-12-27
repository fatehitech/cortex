import IEx 

defmodule Cortex.Worker.Mapper do
  use GenServer
  import Ecto.Query

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    state = list_tty() |> Enum.map(fn(tty) ->
      {:ok, _pid} = Cortex.Worker.ScanApp.start(tty, self)
      [tty: tty, name: nil]
    end)
    IO.inspect state
    {:ok, state}
  end

  def app_module_code(body, name) do
    name = String.replace(name, ".ino", "")
    content = """
    defmodule Cortex.Thing.Application.#{name} do
      use Cortex.ThingRunner
    """
    body = body
    |> String.split("\n")
    |> Enum.map(fn(line) -> "  "<>line end)
    |> Enum.join("\n")
    content<>"\n"<>body<>"\nend"
end

  def handle_info({:mapped, {tty, baudrate, name}, pid}, devices) do
    Cortex.Worker.ScanApp.stop(pid)
    devices = devices |> find_and_update_by_tty(tty, fn(dev)->
      code = Cortex.Repo.one(from thing in Cortex.Thing, select: thing.code, where: thing.firmware_name == ^name)
      if code do
        module = app_module_code(code, name)
        |> Code.compile_string()
        |> List.first()
        |> elem(0)
        {:ok, pid} = module.start_link(tty, baudrate)
        dev = Keyword.put(dev, :pid, pid)
      else
        dev
      end
      Keyword.put(dev, :name, name)
    end)
    IO.inspect devices
    {:noreply, devices}
  end

  defp list_tty() do
    File.ls!("/dev")
    |> Enum.map(fn(name) -> "/dev/"<>name end)
    |> Enum.filter(fn(name) ->
      cond do
        String.contains?(name, "/dev/cu.usb") ->
          true # mac
        String.contains?(name, "/dev/ttyACM") ->
          true # beaglebone
        true -> false
      end
    end)
  end

  defp find_and_update_by_tty(devices, tty, fun) do
    index = devices |> Enum.find_index(fn(dev) ->
      dev[:tty] === tty
    end)
    devices |> List.update_at(index, fun)
  end
end
