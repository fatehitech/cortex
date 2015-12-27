defmodule Cortex.Worker.ScanApp do
  require Serial
  alias Firmata.Board, as: Board
  use GenServer

  def start(tty, owner) do
    GenServer.start(__MODULE__, [tty, 57600, owner])
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def init([tty, baudrate, owner]) do
    {:ok, board} = Board.start_link
    serial = start_serial(tty, baudrate)
    {:ok, {owner, board, serial, [tty: tty, baudrate: baudrate]}}
  end

  def start_serial(tty, baudrate) do
    {:ok, serial} = Serial.start_link
    Serial.open(serial, tty)
    Serial.set_speed(serial, baudrate)
    Serial.connect(serial)
    serial
  end

  def handle_call(:stop, _from, {_,board, serial, _} = state) do
    GenServer.call(board, :stop)
    Serial.stop(serial)
    {:stop, :normal, :ok, state}
  end

  def handle_info({:firmata, {:version, major, minor}}, {owner, board, serial, info}) do
    info = Keyword.put(info, :firmata_version, {major, minor})
    {:noreply, {owner, board, serial, info}}
  end

  def handle_info({:firmata, {:firmware_name, name}}, {owner, board, serial, info}) do
    info = Keyword.put(info, :firmware_name, name)
    send(owner, {:mapped, {info[:tty], info[:baudrate], name}, self})
    {:noreply, {owner, board, serial, info}}
  end

  def handle_info({:firmata, {:pin_map, pin_map}}, {owner, board, serial, info} = state) do
    {:noreply, state}
  end

  # Forward data over serial port to Firmata

  def handle_info({:elixir_serial, _serial, data}, {_, board, _, _} = state) do
    send(board, {:serial, data})
    {:noreply, state}
  end

  # Send data over serial port when Firmata asks us to

  def handle_info({:firmata, {:send_data, data}}, {_, _, serial, _} = state) do
    Serial.send_data(serial, data)
    {:noreply, state}
  end
end
