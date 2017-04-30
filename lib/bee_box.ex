defmodule BeeBox do
  use Application
  @moduledoc """
   BeeBox is a fault-tolerant OTP chat server
  """

  @doc """
  Hello world.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(BeeBox.Registry, [1]),
      supervisor(BeeBox.ServerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: BeeBox.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
