defmodule Smoke.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Smoke.ConnectionSupervisor, []},
      {Smoke.Server, port: port()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Smoke.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port, do: :smoke |> Application.fetch_env!(:port) |> String.to_integer()
end
