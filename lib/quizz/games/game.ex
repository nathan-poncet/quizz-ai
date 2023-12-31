defmodule Quizz.Games.Game do
  alias Quizz.Games.Player
  alias Quizz.Games.Game
  alias Quizz.Games.Questions

  defstruct current_question: nil,
            id: nil,
            players: [],
            questions: [],
            settings: %{
              min_players: 1,
              max_players: 20,
              nb_questions: 10,
              time_per_question: 10_000,
              time_to_answer: 30_000,
              topic: "",
              difficulty: :easy
            },
            status: :not_started

  def add_player(
        %Game{status: status} =
          _game,
        _player_id
      )
      when status != :not_started,
      do: {:error, "game has already started"}

  def add_player(
        %Game{players: players, settings: %{max_players: max_players}} =
          _game,
        _player_id
      )
      when length(players) >= max_players,
      do: {:error, "game is full or has already started"}

  def add_player(%Game{status: :not_started} = game, player_id),
    do: {:ok, %Game{game | players: game.players ++ [%Player{id: player_id}]}}

  def answer(%Game{players: players} = game, player_id, answer) do
    new_players =
      Enum.map(players, fn player ->
        if player.id == player_id do
          Player.add_answer(player, answer)
        else
          player
        end
      end)

    %Game{game | players: new_players}
  end

  def new(game_id, settings) do
    %Game{id: game_id, settings: settings} |> questions_generate
  end

  def start(%Game{status: status}) when status != :not_started,
    do: {:error, "game has already started"}

  def start(%Game{questions: []}), do: {:error, "no questions generated"}

  def start(%Game{status: :not_started} = game), do: {:ok, %Game{game | status: :in_play}}

  defp questions_generate(%Game{settings: settings} = game) do
    questions = Questions.generate(settings)
    %Game{game | questions: questions}
  end
end
