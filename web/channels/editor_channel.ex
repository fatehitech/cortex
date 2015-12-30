defmodule Cortex.EditorChannel do
  use Cortex.Web, :channel

  def join("editor:linter", _params, socket) do
    {:ok, socket}
  end

  def handle_in("check_code", params, socket) do
    try do
      Code.compile_string(params["code"])
      {:reply, :ok, socket}
    rescue
      err -> {:reply, {:error, err}, socket}
    end
  end

  def compile(code) do
  end
end
