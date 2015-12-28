defmodule Cortex.ThingCode do
  def default do
    String.strip ~S"""
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
        {:ok, {board, serial}}
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
