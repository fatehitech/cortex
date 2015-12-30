defmodule Cortex.Thing.Code.Boilerplate.Series do
  def body(module_name) do
    """
    # define one or more time series
    defmodule #{module_name}.MySeries do
      use Instream.Series

      series do
        database    :my_database
        measurement :my_measurement

        tag :foo
        tag :bar

        field :value
      end
    end
    """
  end
end
