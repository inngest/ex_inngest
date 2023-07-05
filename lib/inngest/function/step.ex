defmodule Inngest.Function.Step do
  @moduledoc """
    A struct representing a function step
  """

  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :step_type,
    :tags,
    :mod,
    :runtime,
    :retries,
    :state
  ]

  @type t() :: %__MODULE__{
          id: atom(),
          name: binary(),
          step_type: :step_run | :step_sleep,
          tags: map(),
          mod: module(),
          runtime: RunTime,
          retries: Retry,
          state: any()
        }

  defmodule RunTime do
    @moduledoc """
    A struct representing step runtime, currently only supports HTTP
    """
    @derive Jason.Encoder
    defstruct [
      :url,
      type: "http"
    ]

    @type t() :: %__MODULE__{
            type: binary(),
            url: binary()
          }
  end

  defmodule Retry do
    @moduledoc """
    A struct representing step retries
    """
    @derive Jason.Encoder
    defstruct attempts: 3

    @type t() :: %__MODULE__{
            attempts: number()
          }
  end
end
