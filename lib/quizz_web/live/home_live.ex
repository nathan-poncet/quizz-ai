defmodule QuizzWeb.HomeLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <.link href={~p"/create-game"}>Create a Quizz</.link>
    <.link href={~p"/join-game"}>Join a quiz</.link>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
