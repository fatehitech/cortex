defmodule Cortex.ThingRunner do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Serial
      use Firmata.Protocol.Modes
      alias Firmata.Board, as: Board

      @high 1
      @low 0


      def start_link(tty, baudrate, opts \\ []) do
        GenServer.start_link(__MODULE__, [tty, baudrate], opts)
      end

      def init([tty, baudrate]) do
        IO.puts "starting"
        {:ok, serial} = Serial.start_link
        {:ok, board} = Board.start_link
        Serial.open(serial, tty)
        Serial.set_speed(serial, baudrate)
        Serial.connect(serial)
        {:ok, {board, serial}}
      end

      # Forward data over serial port to Firmata

      def handle_info({:elixir_serial, _serial, data}, {board, _} = state) do
        send(board, {:serial, data})
        {:noreply, state}
      end

      # Send data over serial port when Firmata asks us to

      def handle_info({:firmata, {:send_data, data}}, {_, serial} = state) do
        Serial.send_data(serial, data)
        {:noreply, state}
      end
    end
  end
end
