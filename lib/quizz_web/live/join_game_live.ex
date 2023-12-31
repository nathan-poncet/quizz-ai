defmodule QuizzWeb.JoinGameLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Join a Quizz</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
