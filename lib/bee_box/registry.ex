defmodule BeeBox.Registry do
  use GenServer
  require Logger

  ### API
  def start_link(count) do
    GenServer.start_link(__MODULE__, count, [name: __MODULE__])
  end

  def get_clients do
    :ets.tab2list(:clients)
  end

  def add_client(new_client) do
    GenServer.cast(__MODULE__, {:add_client, new_client})
  end

  def remove_client(client) do
    GenServer.cast(__MODULE__, {:remove_client, client})
  end

  ### GENSERVER IMPLEMENTATION

  def handle_cast({:add_client, new_client}, count) do
    :ets.insert(:clients, {new_client, count})
    Logger.info [
      "#{inspect new_client}: ",
      "User ##{count} ",
      "has joined the chatroom"
    ]

    {:noreply, count + 1}
  end

  def handle_cast({:remove_client, client}, count) do
    :ets.delete(:clients, client)

    {:noreply, count}
  end

  def handle_info(msg, state) do
    Logger.warn ["Unrecognised message: ", "#{inspect msg}"]

    {:noreply, state}
  end

  def init(count) do
    :ets.new(:clients, [:set, :protected, :named_table])
    Logger.info "initiating BeeBox Registry"

    {:ok, count}
  end
end
