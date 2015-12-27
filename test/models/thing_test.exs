defmodule Cortex.ThingTest do
  use Cortex.ModelCase

  alias Cortex.Thing

  @valid_attrs %{code: "some content", firmware_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Thing.changeset(%Thing{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Thing.changeset(%Thing{}, @invalid_attrs)
    refute changeset.valid?
  end
end
