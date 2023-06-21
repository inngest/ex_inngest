defmodule Inngest.Function do
  alias Inngest.Function.Args

  @moduledoc """
  Module to be used within user code to setup an Inngest function.
  Making it servable and invokable.
  """

  @doc """
  Returns the function's human-readable ID, such as "sign-up-flow"
  """
  @callback slug() :: String.t()

  @doc """
  Returns the function name
  """
  @callback name() :: String.t()

  @doc """
  Returns the function's configs
  """
  @callback config() :: any()

  @doc """
  Returns the event name or schedule that triggers the function
  """
  @callback trigger() :: Inngest.Function.Trigger.t()

  @doc """
  Returns the zero event type to marshal the event into, given an
  event name
  """
  @callback zero_event() :: any()

  @doc """
  Returns the SDK function to call. This must alawys be of type SDKFunction,
  but has an any type as we register many functions of different types into a
  type-agnostic handler; this is a generic implementation detail, unfortunately.
  """
  @callback func() :: any()

  @callback perform(Args.t()) :: map() | nil

  defmacro __using__(opts) do
    quote location: :keep do
      alias Inngest.Function.Trigger
      @behaviour Inngest.Function

      @opts unquote(opts)

      @impl true
      def slug() do
        if Keyword.get(@opts, :id),
          do: Keyword.get(@opts, :id),
          else:
            Keyword.get(@opts, :name)
            |> String.replace(~r/[\.\/\s]+/, "-")
            |> String.downcase()
      end

      @impl true
      def name(), do: Keyword.get(@opts, :name)

      @impl true
      def config(), do: %{}

      @impl true
      def trigger(), do: @opts |> Map.new() |> trigger()
      defp trigger(%{event: event} = _opts), do: %Trigger{event: event}
      defp trigger(%{cron: cron} = _opts), do: %Trigger{cron: cron}

      @impl true
      def zero_event(), do: "placeholder"

      @impl true
      def func(), do: __MODULE__

      def steps(),
        do: %{
          "step" => %{
            id: "step",
            name: "step",
            runtime: %{
              type: "http",
              url: "http://127.0.0.1:4000/api/inngest?fnId=#{name()}&step=step"
            },
            retries: %{
              attempts: 3
            }
          }
        }

      def serve() do
        %{
          id: slug(),
          name: name(),
          triggers: [trigger()],
          steps: steps(),
          mod: __MODULE__
        }
      end
    end
  end

  # TODO: This is required for the local dev UI
  # Implement it when addressing that.
  def from(_) do
    %{}
  end
end

defmodule Inngest.Function.Step do
  @moduledoc false

  defstruct [
    :id,
    :name,
    :path,
    :retries,
    :runtime
  ]
end
