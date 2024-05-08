defmodule DuckDuckGooseWeb.StatusController do
  use DuckDuckGooseWeb, :controller

  def status(conn, _) do
    text(conn, DuckDuckGoose.Nodes.Manager.get_type())
  end
end