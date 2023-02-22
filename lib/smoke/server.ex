defmodule Smoke.Server do
  use Task, restart: :transient

  require Logger

  def start_link(opts) do
    Task.start_link(__MODULE__, :run, [Keyword.fetch!(opts, :port)])
  end

  @spec run(:inet.port_number()) :: no_return()
  def run(port) do
    case :gen_tcp.listen(port, [
           :binary,
           active: :once,
           ifaddr: {0, 0, 0, 0},
           reuseaddr: true,
           exit_on_close: false
         ]) do
      {:ok, listen_socket} ->
        Logger.info("Smoke Server listening on #{port}...")
        accept_loop(listen_socket)

      {:error, reason} ->
        raise "Failed to listen on #{port}: #{inspect(reason)}"
    end
  end

  defp accept_loop(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, socket} ->
        Smoke.ConnectionSupervisor.start_child(socket)
        accept_loop(listen_socket)

      {:error, reason} ->
        raise "Failed to accept connection: #{inspect(reason)}"
    end
  end
end
