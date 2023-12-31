defmodule QuizzWeb.CreateGameLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Create a Quizz</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
