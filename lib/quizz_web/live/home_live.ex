defmodule QuizzWeb.HomeLive do
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center gap-5 h-full">
      <.link
        navigate={~p"/create-game"}
        class={[
          "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
          "text-md font-bold leading-6 text-white active:text-white/80"
        ]}
      >
        Create a Quizz
      </.link>
      <.link
        navigate={~p"/join-game"}
        class={[
          "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
          "text-md font-bold leading-6 text-white active:text-white/80"
        ]}
      >
        Join a quiz
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
