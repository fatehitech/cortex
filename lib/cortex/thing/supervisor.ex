import IEx

defmodule Cortex.Thing.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def start_device(pid, tty_path, module) do
    Supervisor.start_child(pid, worker(module, [tty_path, 57600]))
  end

  def stop_device(pid, child_id) do
    :ok = Supervisor.terminate_child(pid, child_id)
    :ok = Supervisor.delete_child(pid, child_id)
  end
end
