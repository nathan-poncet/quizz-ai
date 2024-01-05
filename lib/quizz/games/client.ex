defmodule Quizz.Games.Client do
  require Logger

  alias Quizz.Games.Topics
  alias Quizz.Games.{Server, ServerSupervisor}

  @id_length 16

  def create_game(settings) do
    game_id =
      @id_length
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64()
      |> binary_part(0, @id_length)

    case start_server(game_id, settings) do
      {:ok, pid} ->
        {:ok, Server.game(pid)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete_game(game_id) do
    stop_server(game_id)
  end

  def start_game(game_id) do
    case server(game_id) do
      {:ok, game_server} ->
        Server.start(game_server)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def join_game(game_id, player_id, pid) do
    with {:ok, game_server} <- server(game_id),
         {:ok, _} = join <- Server.join(game_server, player_id, pid) do
      Process.monitor(game_server)
      join
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_game(game_id) do
    case server(game_id) do
      {:ok, game_server} ->
        Server.game(game_server)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def answer(game_id, player_id, answer) do
    case server(game_id) do
      {:ok, game_server} ->
        Server.answer(game_server, player_id, answer)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def topics_generate(_topics) do
    #  Topics.generate(topics)

    [
      %{"title" => "maths", "img" => "https://picsum.photos/seed/maths/200/300"},
      %{"title" => "history", "img" => "https://picsum.photos/seed/history/200/300"},
      %{"title" => "geography", "img" => "https://picsum.photos/seed/geography/200/300"},
      %{"title" => "science", "img" => "https://picsum.photos/seed/science/200/300"},
      %{"title" => "sport", "img" => "https://picsum.photos/seed/sport/200/300"},
      %{"title" => "music", "img" => "https://picsum.photos/seed/music/200/300"},
      %{"title" => "cinema", "img" => "https://picsum.photos/seed/cinema/200/300"}
    ]
  end

  defp server(game_id) do
    case Server.whereis(game_id) do
      :undefined ->
        {:error, :game_doesnt_exist}

      game_server ->
        {:ok, game_server}
    end
  end

  defp start_server(game_id, settings) do
    case ServerSupervisor.start_child(game_id, settings) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp stop_server(game_id) do
    game_id |> server |> handle_stop_server
  end

  defp handle_stop_server({:error, reason}), do: {:error, reason}
  defp handle_stop_server(:ok), do: :ok

  defp handle_stop_server({:ok, game_server}) do
    ServerSupervisor.terminate_child(game_server)
    |> handle_stop_server
  end
end
