defmodule FuelApp.Application do
  @moduledoc """
  The `FuelApp.Application` starts a supervisor and passes the `FuelApp.FuelCalculationServer` as a child process.

  The options configured for the Supervisor ensure that if a child fails more than 3 times in 5 seconds, the Supervisor
  itself will terminate.

  This Supervisor uses the `:one_for_one` strategy, meaning if a single child process terminates, only that
  process is restarted. This is appropriate for our application since each fuel calculation process is independent,
  but also because we only have one child. If we had a GenServer that maintained the list of know planets, for example,
  then we could start that before the fuel calculation started and we could use a `:rest_for_one` strategy
  where if the fuel calculation process failed, the planets process would not need to be restarted.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Restart the FuelCalculationServer in case of failure.
      {FuelApp.FuelCalculationServer, restart: :permanent}
    ]

    # These options tell the supervisor to terminate if it restarts more than 3 times in 5 seconds.
    opts = [
      strategy: :one_for_one,
      name: FuelApp.Supervisor,
      max_restarts: 3,
      max_seconds: 5
    ]

    Supervisor.start_link(children, opts)
  end
end
