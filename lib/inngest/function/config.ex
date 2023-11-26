defmodule Inngest.FnOpts do
  @moduledoc false

  defstruct [
    :id,
    :name,
    :debounce,
    :batch_events,
    retries: 3
  ]

  alias Inngest.Util

  @type t() :: %__MODULE__{
          id: binary(),
          name: binary(),
          retries: number() | nil,
          debounce: debounce() | nil,
          batch_events: batch_events() | nil
        }

  @type debounce() :: %{
          key: nil | binary(),
          period: binary()
        }

  @type batch_events() :: %{
          max_size: number(),
          timeout: binary()
        }

  @doc """
  Validate the debounce configuration
  """
  @spec validate_debounce(t(), map()) :: map()
  def validate_debounce(fnopts, config) do
    case fnopts |> Map.get(:debounce) do
      nil ->
        config

      debounce ->
        period = Map.get(debounce, :period)

        if is_nil(period) do
          raise Inngest.InvalidDebounceConfigError
        end

        case Util.parse_duration(period) do
          {:error, error} ->
            raise Inngest.InvalidDebounceConfigError, message: error

          {:ok, seconds} ->
            # credo:disable-for-next-line
            if seconds > 7 * Util.day_in_seconds() do
              raise Inngest.InvalidDebounceConfigError,
                message: "cannot specify period for more than 7 days"
            end
        end

        Map.put(config, :debounce, debounce)
    end
  end

  @doc """
  Validate the event batch config
  """
  @spec validate_batch_events(t(), map()) :: map()
  def validate_batch_events(fnopts, config) do
    case fnopts |> Map.get(:batch_events) do
      nil ->
        config

      batch ->
        max_size = Map.get(batch, :max_size)
        timeout = Map.get(batch, :timeout)

        if is_nil(max_size) do
          raise Inngest.InvalidBatchEventConfigError,
            message: "'max_size' must be set for batch_events"
        end

        if is_nil(timeout) do
          raise Inngest.InvalidBatchEventConfigError,
            message: "'timeout' must be set for batch_events"
        end

        case Util.parse_duration(timeout) do
          {:error, error} ->
            raise Inngest.InvalidBatchEventConfigError, message: error

          {:ok, seconds} ->
            # credo:disable-for-next-line
            if seconds < 1 || seconds > 60 do
              raise Inngest.InvalidBatchEventConfigError,
                message: "'timeout' duration set to '#{timeout}', needs to be 1s - 60s"
            end
        end

        batch = batch |> Map.put(:maxSize, max_size) |> Map.drop([:max_size])
        Map.put(config, :batchEvents, batch)
    end
  end
end
