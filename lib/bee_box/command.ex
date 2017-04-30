defmodule BeeBox.Command do
  require Logger

  def parse(line, client) do
    case line do
      "EXIT\r\n" -> {:ok, {:exit, client}}
      line -> {:ok, {:emit, client, line}}
    end
  end

  def run({:exit, client}) do
    :gen_tcp.send(client, "You have left the chat room\r\n")
    BeeBox.Registry.remove_client(client)
    exit(:shutdown)
  end

  def run({:emit, client, line}) do
    BeeBox.Messenger.emit_message(client, line)
  end

  def run(_) do
    Logger.warn "Unknown Command"
  end
end
