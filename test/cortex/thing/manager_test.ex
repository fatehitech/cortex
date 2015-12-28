defmodule Cortex.Thing.ManagerTest do
  use ExUnit.Case

  # test update_tty_list

  test "update_tty_list/2 makes correct tty list when seen nothing yet" do
    sys_tty = ["/dev/ttyACM0", "/dev/ttyACM1"]
    seen_tty = []
    out = Cortex.Thing.Manager.update_tty_list(sys_tty, seen_tty)
    assert out == [
      {"/dev/ttyACM0", nil, 0},
      {"/dev/ttyACM1", nil, 0}
    ]
  end

  test "update_tty_list/2 makes correct list when seen one of them" do
    sys_tty = ["/dev/ttyACM0", "/dev/ttyACM1"]
    seen_tty = [{"/dev/ttyACM1", "Uno", 1}]
    out = Cortex.Thing.Manager.update_tty_list(sys_tty, seen_tty)
    assert out == [
      {"/dev/ttyACM0", nil, 0},
      {"/dev/ttyACM1", "Uno", 1}
    ]
  end

  test "update_tty_list/2 makes correct list when one disappears" do
    sys_tty = ["/dev/ttyACM0"]
    seen_tty = [{"/dev/ttyACM1", "Uno", 1}]
    out = Cortex.Thing.Manager.update_tty_list(sys_tty, seen_tty)
    assert out == [
      {"/dev/ttyACM0", nil, 0}
    ]
  end

  # identify

  test "identify/1 changes status of tty from 0 to 1 and sends connect message" do
    list = [{"/dev/ttyACM0", nil, 0},{"/dev/ttyACM1", nil, 1}]
    out = Cortex.Thing.Manager.identify(list)
    assert out == [
      {"/dev/ttyACM0", nil, 1},
      {"/dev/ttyACM1", nil, 1}
    ]
    assert_receive({ :connect, "/dev/ttyACM0" })
    refute_receive({ :connect, "/dev/ttyACM1" })
  end

  # identified

  test "identified/3 updates ttys with the one with given path identified and sends disconnect message" do
    list = [{"/dev/ttyACM0", nil, 1},{"/dev/ttyACM1", nil, 1}]
    out = Cortex.Thing.Manager.identified(list, "/dev/ttyACM1", "Uno.ino")
    assert out == [
      {"/dev/ttyACM0", nil, 1},
      {"/dev/ttyACM1", "Uno.ino", 2}
    ]
    assert_receive({ :disconnect, "/dev/ttyACM1" })
    refute_receive({ :disconnect, "/dev/ttyACM0" })
  end

  # disconnect

  test "disconnect/3 removes the element with with the matching tty name and calls the callback with it" do
    list = [{"/dev/ttyACM0", "hello"},{"/dev/ttyACM1", "world"}]
    out = Cortex.Thing.Manager.disconnect(list, "/dev/ttyACM1", fn(value) ->
      assert value == "world"
    end)
    assert out == [ {"/dev/ttyACM0", "hello" } ]
  end

  test "remove_connected/2" do
    ttys = [{"/dev/ttyACM0", nil, 0},{"/dev/ttyACM1", nil, 1},{"/dev/ttyACM2", "Uno", 2}]
    ttys_out = Cortex.Thing.Manager.remove_connected(ttys)
    assert ttys_out == [ {"/dev/ttyACM0", nil, 0 }, {"/dev/ttyACM2", "Uno", 2 } ]
  end
end