defmodule Inngest.Router.HelperTest do
  use ExUnit.Case, async: true

  alias Inngest.Router.Helper

  describe "func_map/2" do
    test "should return a function map" do
      path = "/api/inngest"
      funcs = [Inngest.TestEventFn]

      assert %{
               "test-event" => %{
                 id: "test-event",
                 mod: Inngest.TestEventFn,
                 steps: %{
                   step: %Inngest.Function.Step{
                     id: :step,
                     name: "step"
                   }
                 },
                 triggers: [
                   %Inngest.Trigger{
                     event: "my/awesome.event",
                     expression: nil,
                     cron: nil
                   }
                 ]
               }
             } = Helper.func_map(funcs, path)
    end
  end

  describe "load_functions_from_path/1" do
    @path "test/support/**/*.ex"
    @paths ["dev/**/*.ex", @path]

    @dev_mods [Inngest.Dev.EventFn, Inngest.Dev.CronFn]
    @test_mods [Inngest.TestEventFn, Inngest.TestCronFn]

    @tag :skip
    test "should compile all modules in the provided path" do
      assert %{funcs: funcs} = Helper.load_functions_from_path(%{path: @path})
      assert Enum.count(funcs) == Enum.count(@test_mods)

      for mod <- funcs do
        assert Enum.member?(@test_mods, mod)
      end
    end

    @tag :skip
    test "should compile all modules in the provided paths" do
      expected = @dev_mods ++ @test_mods

      assert %{funcs: funcs} = Helper.load_functions_from_path(%{path: @paths})
      assert Enum.count(funcs) == Enum.count(expected)

      for mod <- funcs do
        assert Enum.member?(expected, mod)
      end
    end

    test "should not update the map if path is not provided" do
      assert %{funcs: [10]} = Helper.load_functions_from_path(%{funcs: [10]})
    end
  end
end
