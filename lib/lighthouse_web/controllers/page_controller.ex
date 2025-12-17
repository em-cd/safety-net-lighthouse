defmodule LighthouseWeb.PageController do
  use LighthouseWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
