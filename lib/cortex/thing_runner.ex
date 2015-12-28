defmodule Cortex.ThingRunner do
  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Serial
      use Firmata.Protocol.Modes
      alias Firmata.Board, as: Board

      @high 1
      @low 0

      def stop(pid) do
        GenServer.call(pid, :stop)
      end

      def handle_call(:stop, _from, state) do
        state |> elem(0) |> GenServer.call(:stop)
        state |> elem(1) |> Serial.stop()
        {:stop, :normal, :ok, state}
      end

      # Forward data over serial port to Firmata

      def handle_info({:elixir_serial, _serial, data}, state) do
        state |> elem(0) |> send({:serial, data})
        {:noreply, state}
      end

      # Send data over serial port when Firmata asks us to

      def handle_info({:firmata, {:send_data, data}}, state) do
        state |> elem(1) |> Serial.send_data(data)
        {:noreply, state}
      end
    end
  end
end
