defmodule QuizzWeb.CreateGameLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center gap-5 h-full">
      <.button phx-click="create-game">Create a Quizz</.button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
