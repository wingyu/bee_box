defmodule BeeBox.ServerSupervisor do
  use Supervisor

  def start_link do
    opts = [
      name: __MODULE__,
      strategy: :one_for_one
    ]

    children = [
      supervisor(Task.Supervisor, [[name: BeeBox.MessengerTaskSupervisor]]),
      supervisor(Task.Supervisor, [[name: BeeBox.ServerTaskSupervisor]]),
      worker(Task, [BeeBox.Server, :accept, [4040]])
    ]

    Supervisor.start_link(children, opts)
  end
end
