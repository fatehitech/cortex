defmodule Cortex.Thing.ManagerTest do
  use ExUnit.Case

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

  test "lost_knowns/2 reveals which known ttys we lost" do
    prev_tty = [{"/dev/ttyACM1", "Uno", 2},{"/dev/ttyACM2", "Metro", 1}]
    new_tty = [ {"/dev/ttyACM0", nil, 0} ]
    out = Cortex.Thing.Manager.lost_knowns(prev_tty, new_tty)
    assert out == [
      {"/dev/ttyACM1", "Uno", 2}
    ]
  end

  test "lost_knowns/2 reveals which known ttys we lost" do
    prev_ttys = [{"/dev/cu.usbserial-ADAOLOS6z", "Metro.ino", 2}]
    new_ttys = [{"/dev/cu.usbserial-ADAOLOS6z", "Metro.ino", 2},{"/dev/cu.usbmodem1411", "Uno.ino", 2}]
    out = Cortex.Thing.Manager.lost_knowns(prev_ttys, new_ttys)
    assert out == [
      {"/dev/cu.usbmodem1411", "Uno.ino", 2}
    ]
  end

  test "identify/1 changes status of tty from 0 to 1 and sends connect message" do
    list = [{"/dev/ttyACM0", nil, 0},{"/dev/ttyACM1", nil, 1}, {"/dev/ttyACM2", "Uno", 2}]
    out = Cortex.Thing.Manager.identify(list)
    assert out == [
      {"/dev/ttyACM0", nil, 1},
      {"/dev/ttyACM1", nil, 1},
      {"/dev/ttyACM2", "Uno", 2}
    ]
    assert_receive({ :probe, "/dev/ttyACM0" })
    refute_receive({ :probe, "/dev/ttyACM1" })
    refute_receive({ :probe, "/dev/ttyACM2" })
  end

  test "identified/3 updates ttys with the one with given path identified and sends unprobe message" do
    list = [{"/dev/ttyACM0", nil, 1},{"/dev/ttyACM1", nil, 1}]
    out = Cortex.Thing.Manager.identified(list, "/dev/ttyACM1", "Uno.ino")
    assert out == [
      {"/dev/ttyACM0", nil, 1},
      {"/dev/ttyACM1", "Uno.ino", 2}
    ]
    assert_receive({ :unprobe, "/dev/ttyACM1" })
    refute_receive({ :unprobe, "/dev/ttyACM0" })
  end

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
