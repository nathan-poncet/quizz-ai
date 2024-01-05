defmodule QuizzWeb.CreateGameLive do
  alias Quizz.Games
  use QuizzWeb, :live_view

  def render(assigns) do
    ~H"""
    <div id="create_game" class="container mx-auto space-y-8">
      <.form for={@form} id="create_game_form" phx-submit="submit" class="space-y-4 mx-auto">
        <.input field={@form[:id]} type="text" label="Game ID" required />
        <.button phx-disable-with="Create game..." class="w-full">
          Create Game
        </.button>
      </.form>

      <.async_result :let={topics} assign={@topics}>
        <:loading>
          <p>Loading topics...</p>
        </:loading>
        <:failed :let={_reason}>
          <p>there was an error loading the topics</p>
        </:failed>

        <div class="grid gap-4" style="grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));">
          <article :for={topic <- topics} class="group">
            <img
              alt="Lava"
              src={topic["img"]}
              class="h-56 w-full rounded-xl object-cover shadow-xl transition group-hover:grayscale-[50%]"
            />

            <div class="p-4">
              <a href="#">
                <h3 class="text-lg font-medium text-gray-900"><%= topic["title"] %></h3>
              </a>
            </div>
          </article>
        </div>
      </.async_result>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:topics, fn -> {:ok, %{topics: Games.topics_generate([])}} end)
      |> assign(:form, to_form(%{"id" => ""}, as: :create_game))

    {:ok, socket}
  end

  def handle_event("submit", %{"id" => id}, socket) do
    case Games.Client.fetch_game(id) do
      {:ok, _game} ->
        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Game with id: '#{id}' doesn't exist")}
    end
  end
end
