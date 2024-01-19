defmodule QuizzWeb.GameLive do
  use QuizzWeb, :live_view

  require Logger

  alias Quizz.Games.Game
  #  alias Quizz.Games

  def render(assigns) do
    ~H"""
    <h1>Hi from game <%= @game.id %></h1>
    <pre><%= inspect(@game) %></pre>
    <pre><%= inspect(@current_user) %></pre>
    """
  end

  on_mount {QuizzWeb.UserAuth, :ensure_authenticated}

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Quizz.PubSub, "game:#{id}")
    end

    #  case Games.join_game(id, socket.id, self()) do
    #    {:ok, game} ->
    #      {:ok, assign(socket, :game, game)}
    #  
    #    {:error, _reason} ->
    #      {:error, socket |> put_flash(:error, "Game with id: '#{id}' doesn't exist")}
    #  end
    {:ok, socket |> assign(:game, %Game{})}
  end

  def handle_info(%{event: "game:updated", payload: game}, socket) do
    {:noreply, assign(socket, :game, game) |> put_flash(:info, "Game updated")}
  end
end
