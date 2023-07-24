<p align="center">
  <a href="https://www.inngest.com">
    <img alt="Inngest logo" src="https://user-images.githubusercontent.com/306177/191580717-1f563f4c-31e3-4aa0-848c-5ddc97808a9a.png" width="350" />
  </a>
</p>

<p align="center">
  Effortless queues, background jobs, and workflows. <br />
  Easily develop workflows in your current codebase, without any new infrastructure.
</p>

<!-- MDOC ! -->

<p align="center">
  <a href="https://github.com/darwin67/ex-inngest/actions/workflows/ci.yml">
    <img src="https://github.com/darwin67/ex-inngest/actions/workflows/ci.yml/badge.svg" />
  </a>
  <a href="https://discord.gg/EuesV2ZSnX">
    <img src="https://img.shields.io/discord/842170679536517141?label=discord" />
  </a>
  <a href="https://twitter.com/inngest">
    <img src="https://img.shields.io/twitter/follow/inngest?style=social" />
  </a>
</p>


Inngest is an event driven platform that helps you build reliable background jobs and
workflows effortlessly.

Using our SDK, easily add retries, queues, sleeps, cron schedules, fan-out jobs, and
reliable steps functions into your existing projects. It's deployable to any platform,
without any infrastructure. We do the hard stuff so you can focus on building what you
want.
And, everything is locally testable via our Dev server.

## Installation

The Elixir SDK can be downloaded from Hex. Add it to your list of dependencies in `mix.exs`

``` elixir
# mix.exs
def deps do
  [
    {:inngest, "~> 0.1"}
  ]
end
```

### Example

This is a basic example of what an Inngest function will look like.

A Module can be turned into an Inngest function easily by using the `Inngest.Function`
macro.

``` elixir
defmodule MyApp.AwesomeFunction do
  use Inngest.Function,
    name: "awesome function", # The name of the function
    event: "func/awesome"     # The event this function will react to

  # Declare a "run" macro that runs contains the business logic
  run "hello world" do
    {:ok, %{result: "hello world"}}
  end
end
```

The Elixir SDK follows `ExUnit`'s pattern of accumulative macros, where each block
is a self contained piece of logic.

You can declare multiple blocks of `run` or other available macros, and the function
will execute the code in the order it is declared.

#### Advanced

Here's a slightly more complicated version, which should provide you an idea what is
capable with Inngest.

``` elixir
defmodule MyApp.AwesomeFunction do
  use Inngest.Function,
    name: "awesome function", # The name of the function
    event: "func/awesome"     # The event this function will react to

  # An Inngest function will automatically retry when it fails

  # "run" is a normal unit execution. It is not memorized and will be
  # executed every time the function gets re-invoked.
  #
  # The return "data" from each execution block will be accumulated
  # and passed on to the next execution
  run "1st run" do
    {:ok, %{run: "do something"}}
  end

  # "step" is a unit execution where the return value will be memorized.
  # An already executed "step" will not be executed again when re-invoked
  # and will use the previously returned value
  #
  # e.g. The previous `%{run: "do something"}` can be extracted out via
  # pattern matching, just like how you do it in `ExUnit`
  step "1st step", %{data: %{run: output}} do
    {:ok, %{hey: output}}
  end

  # "sleep" will pause the execution for the declared amount of duration.
  sleep "2s"

  step "2nd step" do
    {:ok, %{yo: "lo"}}
  end

  # "sleep" can also sleep until a valid datetime string
  sleep "until July 31 2023 - 8pm", do: "2023-07-18T07:31:00Z"

  # "wait_for_event" will pause the function execution until the declared
  # event is received
  wait_for_event "test/wait", do: [timeout: "1d", match: "data.yo"]

  step "result", %{data: data} do
    {:ok, %{result: data}}
  end
end
```

See the [guides][hexdocs] for more details regarding use cases and how each macros can be used.

<!-- MDOC ! -->

[inngest]: https://www.inngest.com
[hex]: https://hex.pm/packages/inngest
[hexdocs]: https://hexdocs.pm/inngest
