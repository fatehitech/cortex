defmodule Cortex.ThingCode do
  def default do
    String.strip ~S"""
    def handle_info({:firmata, {:pin_map, _pin_map}}, state) do
      {:noreply, state}
    end
    """
  end

  def module_name(name) do
    basename =
      name
      |> String.replace(".ino", "")
      |> String.capitalize()
    ~s(Elixir.#{basename})
  end

  def body_string_to_module_string(body, name) do
    content = """
    defmodule #{module_name(name)} do
      use Cortex.ThingRunner
    """
    body = body
    |> String.split("\n")
    |> Enum.map(fn(line) -> "  "<>line end)
    |> Enum.join("\n")
    content<>"\n"<>body<>"\n\n"<>"""
      def start_link(tty, baudrate) do
        GenServer.start_link(__MODULE__, [tty, baudrate], [])
      end

      def init([tty, baudrate]) do
        {:ok, serial} = Serial.start_link
        {:ok, board} = Board.start_link
        Serial.open(serial, tty)
        Serial.set_speed(serial, baudrate)
        Serial.connect(serial)
        {:ok, {board, serial, tty}}
      end

      def handle_info({:firmata, {:version, _major, _minor}}, state) do
        {:noreply, state}
      end

      def handle_info({:firmata, {:firmware_name, _name}}, state) do
        {:noreply, state}
      end
    end
    """
  end

  def to_module(body, name) do
    body_string_to_module_string(body, name)
    |> Code.compile_string()
    |> List.first()
    |> elem(0)
  end
end
