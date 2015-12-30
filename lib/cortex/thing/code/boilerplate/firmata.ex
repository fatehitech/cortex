# stubs to prevent errors in web editor pertaining to the code below
defmodule Serial do
end

defmodule Firmata.Protocol.Modes do
end

defmodule Firmata.Board do
end

defmodule Cortex.Thing.Code.Boilerplate.Firmata do
  def body(module_name) do
    """
    defmodule #{module_name} do
      use GenServer
      require Serial
      use Firmata.Protocol.Modes
      alias Firmata.Board, as: Board

      @high 1
      @low 0

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

      def handle_info({:firmata, {:pin_map, _pin_map}}, state) do
        # ready!
        {:noreply, state}
      end

      # forward serial data to firmata parser
      def handle_info({:elixir_serial, _serial, data}, {board, _} = state) do
        send(board, {:serial, data})
        {:noreply, state}
      end

      # forward firmata output to serial port
      def handle_info({:firmata, {:send_data, data}}, {_, serial} = state) do
        Serial.send_data(serial, data)
        {:noreply, state}
      end
    end
    """
  end
end
