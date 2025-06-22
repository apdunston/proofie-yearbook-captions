defmodule ProofieWeb.PageController do
  use ProofieWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
