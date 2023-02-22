defmodule Smoke.Connection do
  use GenServer, restart: :temporary

  defstruct [:socket, buffer: "", buffered_size: 0]

  require Logger

  @limit _100_kb = 1024 * 100

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    {:ok, %__MODULE__{socket: socket}}
  end

  @impl true
  def handle_info(message, state)

  def handle_info(
        {:tcp, socket, data},
        %__MODULE__{socket: socket, buffered_size: buffered_size} = state
      )
      when byte_size(data) + buffered_size > @limit do
    Logger.error("Connection closed because of buffer overflow")
    :gen_tcp.close(socket)
    {:stop, :normal, state}
  end

  def handle_info(
        {:tcp, socket, data},
        %__MODULE__{socket: socket, buffer: buffer, buffered_size: buffered_size}
      ) do
    :inet.setopts(socket, active: :once)

    {:noreply,
     %__MODULE__{
       socket: socket,
       buffer: [buffer, data],
       buffered_size: buffered_size + byte_size(data)
     }}
  end

  def handle_info({:tcp_error, socket, reason}, %__MODULE__{socket: socket} = state) do
    Logger.error("Connection closed because of error: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_closed, socket}, %__MODULE__{socket: socket} = state) do
    Logger.debug("Connection closed by client")
    :gen_tcp.send(socket, state.buffer)
    {:stop, :normal, state}
  end
end
