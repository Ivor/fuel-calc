defmodule FuelApp.FuelCalculationServer do
  @moduledoc """
  FuelCalculationServer is a GenServer responsible for calculating the fuel required for spacecraft maneuvers
  based on the given directive (launch or land), mass, and gravitational force of the planet.

  This server handles synchronous calls to perform the fuel calculation and leverages an internal helper
  function to iteratively calculate the required fuel for a given maneuver until a stable result is achieved.

  ## Functions

    * `start_link/1` - Starts the GenServer with optional configurations.
    * `calculate_fuel/3` - Initiates a synchronous call to the server to calculate the required fuel.

  ## Internal Functions

    * `handle_call/3` - Handles the synchronous `calculate_fuel` requests.
    * `do_calculate_fuel/4` - Recursively calculates the fuel needed until a stopping condition is met.
    * `fuel/3` - Computes the fuel requirement based on the directive, mass, and gravity.

  ## Usage

  ```elixir
  # Start the GenServer
  {:ok, pid} = FuelApp.FuelCalculationServer.start_link(name: :fuel_server)
  # Calculate the fuel required for a launch or land maneuver
  fuel = FuelApp.FuelCalculationServer.calculate_fuel(:launch, 1000, 9.807)
  ```

  """

  use GenServer

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, :ok}
  end

  @spec calculate_fuel(atom, number, number) :: number
  def calculate_fuel(directive, mass, gravity) when not is_nil(gravity) and mass > 0 do
    GenServer.call(__MODULE__, {:calculate_fuel, directive, mass, gravity})
  end

  @impl true
  def handle_call({:calculate_fuel, directive, mass, gravity}, _from, state) do
    fuel = do_calculate_fuel(directive, mass, gravity)
    {:reply, fuel, state}
  end

  @spec do_calculate_fuel(atom, number, number, list(number)) :: number
  defp do_calculate_fuel(directive, mass, gravity, list_of_fuel_components \\ [])

  defp do_calculate_fuel(_directive, extra_fuel, _gravity, [extra_fuel | positive_fuel_components])
       when extra_fuel < 0,
       do: Enum.sum(positive_fuel_components)

  defp do_calculate_fuel(directive, mass, gravity, list_of_fuel_components)
       when directive in [:launch, :land] do
    extra_fuel = fuel(directive, mass, gravity)
    do_calculate_fuel(directive, extra_fuel, gravity, [extra_fuel | list_of_fuel_components])
  end

  defp fuel(directive, mass, gravity)
  defp fuel(:launch, mass, gravity), do: trunc(mass * gravity * 0.042 - 33)
  defp fuel(:land, mass, gravity), do: trunc(mass * gravity * 0.033 - 42)
end
