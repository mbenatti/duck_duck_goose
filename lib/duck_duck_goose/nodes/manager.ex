defmodule DuckDuckGoose.Nodes.Manager do
  @moduledoc """
  Coordinates the status and communication among nodes within the DuckDuckGoose cluster.
  """

  use GenServer
  require Logger

  alias DuckDuckGoose.NodeManager.Selection

  @spec start_link(list()) :: GenServer.on_start()
  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      %{type: :duck, master: nil, heartbeat_ref: nil, attempts: 0},
      name: __MODULE__
    )
  end

  @spec init(map()) :: {:ok, map()}
  def init(state) do
    :net_kernel.monitor_nodes(true)

    Selection.schedule(state)
    {:ok, state}
  end

  @spec handle_call(:get_type, {pid(), term()}, map()) :: {:reply, map(), map()}
  def handle_call(:get_type, _from, state) do
    {:reply, state.type, state}
  end

  @spec handle_call({:selection, pid()}, {pid(), term()}, map()) :: {:reply, atom(), map()}
  def handle_call({:selection, caller}, _from, state) do
    case state.type do
       :duck when state.master == nil or state.attempts > 5 ->
        {:reply, :selected, %{state | master: caller, attempts: 0}}

      _ ->
        {:reply, :rejected, %{state | attempts: state.attempts + 1}}
    end
  end

  @spec handle_info({:nodedown, pid()}, map()) :: {:noreply, map()}
  def handle_info({:nodedown, node}, state) do
    if node == state.master do
      Logger.info("nodedown: #{inspect(node)}")
      Selection.schedule(state)
    end

    {:noreply, %{state | master: nil}}
  end

  @spec handle_info({:nodeup, pid()}, map()) :: {:noreply, map()}
  def handle_info({:nodeup, node}, state) do
    Logger.info("nodeup: #{inspect(node)}")
    {:noreply, state}
  end

  @spec handle_info(:select_master, map()) :: {:noreply, map()}
  def handle_info(:select_master, state) do
    Logger.info("Goose selection...")
    new_state = Selection.select_master(state)
    {:noreply, new_state}
  end

  @spec handle_info(:send_heartbeat, map()) :: {:noreply, map()}
  def handle_info(:send_heartbeat, state = %{type: :goose}) do
    Logger.debug("Sending heartbeat...")
    broadcast(:heartbeat, Node.self())
    new_timer = Process.send_after(self(), :send_heartbeat, 1000)

    {:noreply, %{state | heartbeat_ref: new_timer}}
  end

  @spec handle_info({:heartbeat, pid()}, map()) :: {:noreply, map()}
  def handle_info({:heartbeat, master}, state) do
    Logger.debug("Received heartbeat from Goose: #{inspect(master)}")

    if state.heartbeat_ref do
      Process.cancel_timer(state.heartbeat_ref)
    end

    {:noreply, %{state | master: master}}
  end

  @spec handle_info({:master_update, pid()}, map()) :: {:noreply, map()}
  def handle_info({:master_update, master}, state) do
    Logger.debug("New Goose: #{inspect(master)}")

    {:noreply, %{state | master: master}}
  end

  @spec handle_info({:update_type, atom()}, map()) :: {:noreply, map()}
  def handle_info({:update_type, type}, state) do
    {:noreply, %{state | type: type}}
  end

  @spec handle_info(:heartbeat_timeout, map()) :: {:noreply, map()}
  def handle_info(:heartbeat_timeout, state) do
    Logger.error("Heartbeat timeout reached. No heartbeat received from master.")
    state = %{state | master: nil, heartbeat_ref: nil, type: :duck}

    Selection.schedule(state)
    {:noreply, state}
  end

  ### API

  @spec get_type() :: map()
  def get_type do
    GenServer.call(__MODULE__, :get_type)
  end

  @spec heartbeat(atom()) :: :ok
  def heartbeat(node) do
    GenServer.cast(__MODULE__, {:heartbeat, node})
    :ok
  end

  @spec selection(atom()) :: atom()
  def selection(caller) do
    GenServer.call(__MODULE__, {:selection, caller})
  end

  @spec broadcast(atom(), any) :: atom()
  def broadcast(topic, message) do
    Node.list()
    |> Enum.reject(&(&1 == Node.self()))
    |> Enum.each(fn node ->
      send({__MODULE__, node}, {topic, message})
    end)

    :ok
  end
end
