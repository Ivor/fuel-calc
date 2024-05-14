defmodule FuelApp do
  @moduledoc """
  FuelApp is responsible for calculating the total fuel required for a spacecraft to complete a given route,
  considering various planetary gravities and maneuvers.

  ## Known Gravities
  The module recognizes the gravitational forces for the following celestial bodies:
    - Earth: 9.807 m/s²
    - Mars: 3.711 m/s²
    - Moon: 1.62 m/s²

  ## Functions

    * `calculate_fuel/2` - Calculates the total fuel required for the spacecraft based on its mass and the route.
    * `gravity/1` - Retrieves the gravity for a given planet.
    * `valid_route?/1` - Validates the provided route.
  """
  alias FuelApp.FuelCalculationServer

  @known_gravities %{
    "earth" => 9.807,
    "mars" => 3.711,
    "moon" => 1.62
  }

  @spec calculate_fuel(number, list()) :: number | {:error, String.t()}
  @doc """

  Calculates the total fuel required for the spacecraft to complete the given route.

  Usage:

  ```elixir
  FuelApp.calculate_fuel(1000, [{:launch, "earth"}, {:land, "moon"}])
  ```

  ```elixir
  FuelApp.calculate_fuel(1000, [{:launch, "mars"}, {:land, "earth"}])
  ```

  Ensure that the FuelCalculationServer is running before calling `calculate_fuel/2`.
  """
  def calculate_fuel(ship_mass, route) when is_list(route) and is_number(ship_mass) do
    with :ok <- valid_route?(route) do
      route
      |> Enum.reverse()
      |> Enum.reduce(0, fn {directive, planet}, total_fuel ->
        total_fuel +
          FuelCalculationServer.calculate_fuel(directive, total_fuel + ship_mass, gravity(planet))
      end)
    end
  end

  @spec gravity(String.t()) :: number | nil
  @doc """
  Function to retrieve the gravity for a given planet. Returns `nil` if the planet is unknown.
  """
  def gravity(planet) do
    Map.get(@known_gravities, planet)
  end

  @spec valid_route?(list()) ::
          :ok | {:error, :invalid_directive} | {:error, :invalid_planet}
  @doc """
  Validates the provided route to ensure that it contains only known directives and planets.
  """
  def valid_route?(route) do
    Enum.reduce_while(route, :ok, fn {directive, planet}, _valid ->
      with {:directive, true} <- {:directive, directive in [:launch, :land]},
           {:planet, true} <- {:planet, Map.has_key?(@known_gravities, planet)} do
        {:cont, :ok}
      else
        {:directive, false} -> {:halt, {:error, :invalid_directive}}
        {:planet, false} -> {:halt, {:error, :invalid_planet}}
      end
    end)
    |> then(fn
      :ok ->
        validate_continuity(route)
        :ok

      {:error, _} = error ->
        error
    end)
  end

  def validate_continuity(route) do
    route
    |> Enum.zip(Enum.slice(route, 1..-1//1))
    |> Enum.all?(fn
      {{:launch, _}, {:land, _}} -> true
      {{:land, same_planet}, {:launch, same_planet}} -> true
      _ -> false
    end)
  end
end
