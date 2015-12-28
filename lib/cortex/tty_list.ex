defmodule Cortex.TtyList do
  def get do
    File.ls!("/dev")
    |> Enum.map(fn(name) -> "/dev/"<>name end)
    |> Enum.filter(fn(name) ->
      cond do
        String.contains?(name, "/dev/cu.usb") ->
          true # mac
        String.contains?(name, "/dev/ttyACM") ->
          true # beaglebone
        true -> false
      end
    end)
  end
end
