defmodule FuelAppTest do
  use ExUnit.Case

  describe "calculate_fuel/2" do
    test "calculates fuel for apollo11 mission" do
      assert FuelApp.calculate_fuel(28801, [
               {:launch, "earth"},
               {:land, "moon"},
               {:launch, "moon"},
               {:land, "earth"}
             ]) == 51898
    end

    test "calculates fuel for mission to mars" do
      assert FuelApp.calculate_fuel(14606, [
               {:launch, "earth"},
               {:land, "mars"},
               {:launch, "mars"},
               {:land, "earth"}
             ]) == 33388
    end

    test "calculates fuel for passanger ship trip" do
      assert FuelApp.calculate_fuel(75432, [
               {:launch, "earth"},
               {:land, "moon"},
               {:launch, "moon"},
               {:land, "mars"},
               {:launch, "mars"},
               {:land, "earth"}
             ]) == 212_161
    end

    test "calculates fuel for landing on earth" do
      assert FuelApp.calculate_fuel(28801, [{:land, "earth"}]) == 13447
    end

    test "validates errors for invalid input" do
      assert {:error, :invalid_planet} = FuelApp.calculate_fuel(28801, [{:land, "pluto"}])

      assert {:error, :invalid_directive} = FuelApp.calculate_fuel(28801, [{:warp, "earth"}])
    end
  end

  describe "validate_continuity/1" do
    test "valid route with proper continuity" do
      route = [
        {:launch, "earth"},
        {:land, "moon"},
        {:launch, "moon"},
        {:land, "earth"}
      ]

      assert FuelApp.validate_continuity(route) == true
    end

    test "invalid route with no continuity" do
      route = [
        {:launch, "earth"},
        {:land, "moon"},
        {:land, "earth"}
      ]

      assert FuelApp.validate_continuity(route) == false
    end

    test "route starting with land" do
      route = [
        {:land, "earth"},
        {:launch, "earth"},
        {:land, "moon"}
      ]

      assert FuelApp.validate_continuity(route) == true
    end

    test "route with repeated launches" do
      route = [
        {:launch, "earth"},
        {:launch, "moon"},
        {:land, "moon"}
      ]

      assert FuelApp.validate_continuity(route) == false
    end

    test "route with repeated landings" do
      route = [
        {:launch, "earth"},
        {:land, "moon"},
        {:land, "earth"}
      ]

      assert FuelApp.validate_continuity(route) == false
    end

    test "route with valid intermediate stops" do
      route =
        [
          {:launch, "earth"},
          {:land, "moon"},
          {:launch, "moon"},
          {:land, "mars"},
          {:launch, "mars"},
          {:land, "earth"}
        ]

      assert FuelApp.validate_continuity(route) == true
    end

    test "empty route" do
      route = []
      assert FuelApp.validate_continuity(route) == true
    end

    test "single launch route" do
      route = [
        {:launch, "earth"}
      ]

      assert FuelApp.validate_continuity(route) == true
    end

    test "single land route" do
      route = [
        {:land, "earth"}
      ]

      assert FuelApp.validate_continuity(route) == true
    end
  end
end
