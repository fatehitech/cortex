defmodule Cortex.Thing.Code do

  def module_name(name) do
    basename =
      name
      |> String.replace(".ino", "")
      |> String.capitalize()
    ~s(Elixir.Thing.#{basename})
  end

  def to_module(body, name) do
    body
    |> Code.compile_string()
    |> List.first()
    |> elem(0)
  end

  def gen_boilerplate(name, preset) do
    mod = :"Elixir.Cortex.Thing.Code.Boilerplate.#{String.capitalize(preset)}"
    module_name(name)
    |> mod.body()
  end
end
