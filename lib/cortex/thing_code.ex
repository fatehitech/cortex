defmodule Cortex.ThingCode do
  def default do
    String.strip ~S"""
    def init([tty, baudrate]) do
      {:ok, serial} = Serial.start_link
      {:ok, board} = Board.start_link
      Serial.open(serial, tty)
      Serial.set_speed(serial, baudrate)
      Serial.connect(serial)
      {:ok, {board, serial, tty}}
    end

    def handle_info({:firmata, {:version, major, minor}}, state) do
      {:noreply, state}
    end

    def handle_info({:firmata, {:firmware_name, name}}, state) do
      {:noreply, state}
    end

    def handle_info({:firmata, {:pin_map, _pin_map}}, state) do
      {:noreply, state}
    end
    """
  end

  def body_string_to_module_string(body, name) do
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

  def to_module(body, name) do
    body_string_to_module_string(body, name)
    |> Code.compile_string()
    |> List.first()
    |> elem(0)
  end
end
