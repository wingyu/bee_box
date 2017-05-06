defmodule BeeBoxTest do
  use ExUnit.Case
  doctest BeeBox

  setup do
    #Essentially creating a TCP Client here.
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    {:ok, socket: socket}
  end

  test "Starts a chatroom", %{socket: socket} do
    #receive initial welcome message
    :gen_tcp.recv(socket, 0, 1000)

    assert send_and_recv(socket, "invincible cucumber\r\n") ==
      "User #1 says: invincible cucumber\r\n"
  end

  defp send_and_recv(socket, command) do
    #Sending command to Server
    :ok = :gen_tcp.send(socket, command)

    #Receiving message from Server
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
