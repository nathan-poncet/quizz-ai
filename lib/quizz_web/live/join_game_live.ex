defmodule QuizzWeb.JoinGameLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center gap-5 h-full">
      <form phx-change="change" phx-submit="join-game" class="space-y-5">
        <.input type="text" name="game_id" value={@game_id} />
        <.button class="w-full">Join a Quizz</.button>
      </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game_id, "")}
  end

  def handle_event("change", %{"game_id" => game_id}, socket) do
    {:noreply, assign(socket, :game_id, game_id)}
  end
end
