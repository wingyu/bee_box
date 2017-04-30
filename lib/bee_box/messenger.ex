defmodule BeeBox.Messenger do
  def emit_message(sender, message) do
    clients()
      |> segmented_clients
      |> async_send_messages(sender, message)
  end

  defp clients do
    BeeBox.Registry.get_clients
  end

  defp segmented_clients(clients) do
    len = calculate_split(clients)

    Stream.chunk(clients, len)
  end

  defp async_send_messages(segmented_clients, sender, message) do
    Enum.each(segmented_clients, fn(client_segment) ->
      Task.Supervisor.start_child(BeeBox.TaskSupervisor, fn ->
        send_messages(client_segment, sender, message)
      end)
    end)
  end

  defp send_messages(clients, sender, message) do
    [{_sender, id}] = :ets.lookup(:clients, sender)

    Enum.each(clients, fn({client, _}) ->
      :gen_tcp.send(client, ["User ##{id} says: ", message])
    end)
  end

  defp calculate_split(clients) do
    case length(clients)/4 |> round do
      0 ->
        1
      len ->
        len
    end
  end
end
