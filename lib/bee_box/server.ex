defmodule BeeBox.Server do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes

    {:ok, socket} = :gen_tcp.listen(port,
    [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    register_client(client)
    new_server(client)

    loop_acceptor(socket)
  end

  defp new_server(client) do
    {:ok, pid} =  Task.Supervisor.start_child(
      BeeBox.ServerTaskSupervisor, fn -> serve(client) end)

    #This makes the child process the “controlling process” of the client socket.
    #Otherwise the acceptor would bring down all the clients if it crashed
    # because sockets would be tied to the process that accepted them
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  defp register_client(client) do
    BeeBox.Registry.add_client(client)
    :gen_tcp.send(client, "You have joined the chat room!\r\n")
  end

  defp serve(client) do
    with {:ok, data} <- read_line(client),
      {:ok, command} <- BeeBox.Command.parse(data, client),
      do: BeeBox.Command.run(command)

    serve(client)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
end
