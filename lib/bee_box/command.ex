defmodule BeeBox.Command do
  require Logger

  def parse(line, client) do
    case line do
      "EXIT\r\n" -> {:ok, {:exit, client}}
      "\r\n" -> {:ok, :nothing}
      line -> {:ok, {:emit, client, line}}
    end
  end

  def run({:exit, client}) do
    BeeBox.Messenger.emit_message(client, "Left the chatroom\r\n")
    BeeBox.Registry.remove_client(client)
    exit(:shutdown)
  end

  def run({:emit, client, line}) do
    BeeBox.Messenger.emit_message(client, line)
  end

  def run(:nothing) do
    :ok
  end

  def run(_) do
    Logger.warn "Unknown Command"
  end
end
