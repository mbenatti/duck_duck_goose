defmodule DuckDuckGoose.NodeManager.Selection do
  @moduledoc """
  Responsible for the selection logic of the master(goose) among nodes.
  """

  require Logger
  alias DuckDuckGoose.Nodes.Manager

  @spec schedule(map()) :: :ok | no_return()
  def schedule(state) do
    unless Node.ping(state.master) == :pong do
      Logger.info("Scheduling Goose selection...")
      Process.send_after(self(), :select_master, 5000)
    end
  end

  @spec select_master(map()) :: map()
  def select_master(state) do
    if selection() != [] do
      Logger.info("Goose: #{inspect(Node.self())}")

      Manager.broadcast(:master_update, Node.self())

      Process.send_after(self(), :send_heartbeat, 1000)

      %{state | type: :goose, master: Node.self()}
    else
      schedule(state)
      state
    end
  end

  defp selection() do
    Logger.info("Starting Goose selection among nodes...")

    Task.async_stream(
      (Node.list() |> Enum.filter(&(&1 != Node.self()))),
      fn node -> :rpc.call(node, DuckDuckGoose.Nodes.Manager, :selection, [Node.self()]) end,
      timeout: 20_000
    )
    |> Enum.filter(fn
      {:ok, vote} -> vote == :selected
      _ -> false
    end)
  end
end
