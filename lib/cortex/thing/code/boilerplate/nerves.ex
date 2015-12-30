defmodule Cortex.Thing.Code.Boilerplate.Nerves do
  def body(module_name) do
    """
    # nerves example
    defmodule #{module_name} do
    end
    """
  end
end
