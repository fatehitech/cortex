defmodule Cortex.PageController do
  use Cortex.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
