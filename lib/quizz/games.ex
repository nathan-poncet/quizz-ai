defmodule Quizz.Games do
  require Logger
  alias QuizzWeb.Presence
  alias Ecto.Changeset
  alias Quizz.Games.{Game, Server, ServerSupervisor}

  @doc """
  Gets a single game.

  ## Examples

      iex> get_game(123)
      %Game{}

      iex> get_game(456)
      {:error, reason}

  """
  def get_game(game_id) do
    case server(game_id) do
      {:ok, game_server} ->
        {:ok, Server.game(game_server)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, reason}

  """
  def create_game(attrs \\ %{}) do
    changeset = Game.registration_changeset(%Game{}, attrs)
    do_create_game(changeset)
  end

  defp do_create_game(%Changeset{valid?: true, changes: attrs}) do
    with {:ok, pid} <- ServerSupervisor.start_child(attrs),
         game <- Server.game(pid) do
      {:ok, game}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_create_game(%Changeset{valid?: false} = changeset) do
    {:error, Map.put(changeset, :action, :insert)}
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game_id)
      :ok

      iex> delete_game(game_id)
      {:error, reason}

  """
  def delete_game(game_id) do
    with {:ok, game_server} <- server(game_id),
         :ok <- ServerSupervisor.terminate_child(game_server) do
      :ok
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Start a game.

  ## Examples

      iex> start_game(game_id)
      {:ok, %Game{}}

      iex> start_game(bad_value)
      {:error, reason}

  """
  def start_game(game_id) do
    case server(game_id) do
      {:ok, game_server} ->
        Server.start(game_server)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Join a game.

  ## Examples

      iex> join_game(game_id, player_id, pid)
      {:ok, %Game{}}

      iex> join_game(bad_value, player_id, pid)
      {:error, reason}

  """
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

  @doc """
  Answer to question in a game.

  ## Examples

      iex> answer(game_id, player_id, pid)
      {:ok, %Game{}}

      iex> answer(bad_value, bad_value, bad_value)
      {:error, reason}

  """
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game_registration(%Game{} = game, attrs \\ %{}) do
    Game.registration_changeset(game, attrs)
  end

  @doc """
  Get the list of players currently present in the specified game.
  """
  @spec list_presence(Game.join_code()) :: %{optional(Player.id()) => map()}
  def list_presence(join_code) do
    Presence.list("game:" <> join_code)
  end

  defp server(game_id) do
    case Server.whereis(game_id) do
      :undefined ->
        {:error, :game_doesnt_exist}

      game_server ->
        {:ok, game_server}
    end
  end
end
