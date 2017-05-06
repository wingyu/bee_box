defmodule BeeBox.RegistryTest do
  use ExUnit.Case, async: false

  setup do
    #BeeBox.Registry starts before the tests via Application behaviour are even run
    #Alternative would be to not name GenServers
    GenServer.stop(BeeBox.Registry)
    BeeBox.Registry.start_link(1)
    :ok
  end

  test "adds clients" do
    assert BeeBox.Registry.get_clients == []

    BeeBox.Registry.add_client("socket")
    BeeBox.Registry.add_client("another_socket")

    #because adding clients is async, when we call get_clients straight after,
    #the clients wouldn't have been registered yet
    :timer.sleep(100)

    assert BeeBox.Registry.get_clients == [
      {"socket", 1},
      {"another_socket", 2}
    ]
  end

  test "removes clients" do
    BeeBox.Registry.add_client("socket")
    BeeBox.Registry.add_client("another_socket")

    :timer.sleep(100)
    BeeBox.Registry.remove_client("socket")

    :timer.sleep(100)
    assert BeeBox.Registry.get_clients == [
      {"another_socket", 2}
    ]
  end
end
