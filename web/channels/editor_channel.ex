defmodule Cortex.EditorChannel do
  use Cortex.Web, :channel
  import Cortex.Thing.Code, only: [gen_boilerplate: 2]

  def join("editor:lobby", _params, socket) do
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

  def handle_in("boilerplate", %{"preset" => preset, "name" => name}, socket) do
    {:reply, {:ok, %{:code=>gen_boilerplate(name, preset)}}, socket}
  end
end
