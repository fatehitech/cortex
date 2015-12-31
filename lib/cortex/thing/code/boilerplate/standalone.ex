defmodule Cortex.Thing.Code.Boilerplate.Standalone do
  def body(module_name) do
    """
    defmodule #{module_name} do
      use GenServer

      def start_link() do
        GenServer.start_link(__MODULE__, [], [])
      end

      def init([]) do
        {:ok, {}}
      end
    end
    """
  end
end
