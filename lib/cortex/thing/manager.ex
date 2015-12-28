defmodule Cortex.Thing.Manager do
  @moduledoc """
  Loop: identifies each **unknown** and **unconnected** tty by connecting to it and listening
		after 10 seconds
			close the tty
		on receive firmware_name
			report known tty and firmware_name

	For each tty identification
		lookup matching firmware_name in database
			start it up, supervised

  tty list Structure:
  [{tty_name, firmware_name, int:status}, ...]
  """

  @disconnected 0
  @connected 1
  @known 2

  use GenServer

  alias Cortex.Worker.ScanApp, as: Ident

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :thing_manager)
  end

  def init(:ok) do
    ttys = []
    scan_pids = []
    state = {ttys, scan_pids}
    manager = self
    {:ok, state}
  end

  def loop(manager) do
    count = GenServer.call(manager, :tick)
    if count == 0 do
      :timer.sleep 5_000
    else
      :timer.sleep 10_000
    end
    send(manager, :tock)
    loop(manager)
  end

  @doc """
  Causes identification on each unknown and unconnected tty
  """
  def handle_call(:tick, _from, {tty_list, pids} = state) do
    new_tty_list = Cortex.TtyList.get
    |> update_tty_list(tty_list)
    |> identify

    lost_knowns(tty_list, new_tty_list)
    |> Enum.each(fn({path, name, _})->
      IO.puts "lost #{path}"
      send(self(), {:lost, path, name})
    end)

    connected_count = Enum.count(new_tty_list, fn({_,_,state})-> state == @connected end)

    {:reply, connected_count, {new_tty_list, pids}}
  end

  @doc """
  Closes any connected tty running the Firmata identifier
  """
  def handle_info(:tock, {ttys, ident_pids}) do
    ttys = remove_connected(ttys)
    Enum.each(ident_pids, &Ident.stop(elem(&1, 1)))
    {:noreply, {ttys, []}}
  end

  def handle_info({:connect, tty_path}, {tty_list, ident_pids}) do
    IO.puts "connect #{tty_path}"
    {:ok, pid} = Ident.start_link(tty_path, 57600, self())
    {:noreply, {tty_list, [{tty_path, pid}|ident_pids]}}
  end

  def handle_info({:disconnect, tty_path}, {tty_list, ident_pids}) do
    ident_pids = disconnect(ident_pids, tty_path, fn(pid) ->
      IO.puts "stopped #{tty_path}"
      Ident.stop(pid)
    end)
    {:noreply, {tty_list, ident_pids}}
  end

  @doc """
  Received when we have identified a tty to be running Firmata
  At this point it's ready to pass to some process to open and use it
  """
  def handle_info({:identified, tty_path, name}, {tty_list, ident_pids}) do
    IO.puts ">>>>> identified #{tty_path} #{name}"
    {:noreply, {identified(tty_list, tty_path, name), ident_pids}}
  end

  @doc """
  Received when we have lost a known Firmata device
  Stopping any process you started when it was identified
  """
  def handle_info({:lost, tty_path, name}, state) do
    IO.puts ">>>>> lost #{tty_path} #{name}"
    {:noreply, state}
  end

  @doc """
  Takes list of tty tuples and returns a new list with any
  that were in the connected state having been removed
  """
  def remove_connected(ttys) do
    Enum.reduce(ttys, [], fn({path, name, status} = tty, result) ->
      if status == @connected do
        result
      else
        [tty|result]
      end
    end)
    |> Enum.reverse
  end

  @doc """
  takes a list of pid tuples, finds the one with the tty name,
  removes it from the list, calls the callback with it,
  and then returns the list
  """
  def disconnect(ident_pids, tty_path, found_callback) do
    Enum.reduce(ident_pids, [], fn({path, pid} = item, result) ->
      if path == tty_path do
        found_callback.(pid)
        result
      else
        [item|result]
      end
    end)
    |> Enum.reverse()
  end

  @doc """
  Takes a list of tty tuples and updates the one
  with the given path with the given name and status 2
  triggering a disconnect event for it and returning the list
  """
  def identified(ttys, tty_path, firmware_name) do
    Enum.reduce(ttys, [], fn({path, name, status} = tty, result) ->
      if status == @connected and path == tty_path do
        send(self, {:disconnect, path})
        [{path, firmware_name, @known}|result]
      else
        [tty|result]
      end
    end)
    |> Enum.reverse
  end


  @doc """
  Takes a list of tuples and examines the status
  of each one. If 0 we trigger a scan
  and set the status to 1 so we dont trigger again
  returns the list
  """
  def identify(ttys) do
    Enum.reduce(ttys, [], fn({path, name, status} = tty, result) ->
      if status == @disconnected do
        send(self, {:connect, path})
        [{path, name, @connected}|result]
      else
        [tty|result]
      end
    end)
    |> Enum.reverse
  end

  @doc """
  Takes the system tty and current list of seen ttys
  and produces new list of seen ttys by removing or adding
  while converting to desired tuple structure
  """
  def update_tty_list(sys_ttys, seen_ttys) do
    Enum.reduce(sys_ttys, [], fn(sys_tty, result)->
      seen = Enum.find(seen_ttys, &(elem(&1, 0) == sys_tty))
      if seen do
        [seen|result]
      else
        [{sys_tty, nil, 0}|result]
      end
    end)
    |> Enum.reverse
  end

  @doc """
  Reveals which ttys that were otherwise known, are now lost
  """
  def lost_knowns(prev_ttys, new_ttys) do
    Enum.reject(prev_ttys, fn({prev_path, prev_name, status} = prev_tty)->
      status != @known
    end)
    |> Enum.reduce([], fn({prev_path, _, _} = prev_tty, result) ->
      located = Enum.find(new_ttys, false, fn({other_path, _, _}) ->
        prev_path == other_path
      end)
      if located == false do
        [prev_tty|result]
      else
        result
      end
    end)
  end
end
