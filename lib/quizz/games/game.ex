defmodule Quizz.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizz.Games.{Game, GamePlayer, GameQuestion, GameQuestions}

  embedded_schema do
    field :current_question, :integer
    field :difficulty, Ecto.Enum, values: [:easy, :medium, :hard, :genius, :godlike]
    field :nb_questions, :integer
    field :status, Ecto.Enum, values: [:lobby, :in_play, :finished], default: :lobby
    field :time_per_question, :integer, default: 10_000
    field :time_to_answer, :integer, default: 30_000
    field :topic, :string

    embeds_many :players, GamePlayer
    embeds_many :questions, GameQuestion
  end

  def register(
        game_id,
        %{topic: topic, difficulty: difficulty, nb_questions: nb_questions} = params
      ) do
    %Game{
      id: game_id,
      topic: topic,
      difficulty: difficulty,
      nb_questions: nb_questions,
      questions: GameQuestions.generate(params)
    }
  end

  def add_player(%Game{status: :in_play}, _player_id),
    do: {:error, :game_has_already_started}

  def add_player(%Game{status: :lobby} = game, player_id),
    do: {:ok, %Game{game | players: game.players ++ [%GamePlayer{id: player_id}]}}

  def answer(%Game{status: status}, _player_id, _answer) when status != :in_play,
    do: {:error, :game_is_not_in_play}

  def answer(%Game{players: players, status: :in_play} = game, player_id, answer) do
    case Enum.find(players, fn player -> player.id == player_id end) do
      nil ->
        {:error, :player_is_not_in_the_game}

      _ ->
        {:ok, update_answer(game, player_id, answer)}
    end
  end

  def start(%Game{status: status}) when status != :lobby,
    do: {:error, :game_has_already_started}

  def start(%Game{status: :lobby} = game), do: {:ok, %Game{game | status: :in_play}}

  def registration_changeset(game, attrs) do
    game
    |> cast(attrs, [
      :difficulty,
      :nb_questions,
      :topic
    ])
    |> validate_required([
      :difficulty,
      :nb_questions,
      :topic
    ])
    |> validate_number(:nb_questions, greater_than_or_equal_to: 1)
    |> validate_length(:topic, max: 160)
  end

  def update_changeset(game, attrs) do
    game
    |> cast(attrs, [
      :current_question,
      :status,
      :time_per_question,
      :time_to_answer
    ])
    |> validate_required([
      :current_question,
      :status,
      :time_per_question,
      :time_to_answer
    ])
    |> validate_number(:current_question, greater_than_or_equal_to: 0)
    |> validate_number(:time_per_question, greater_than_or_equal_to: 0)
    |> validate_number(:time_to_answer, greater_than_or_equal_to: 0)
  end

  defp update_answer(%Game{players: players} = game, player_id, answer) do
    players =
      Enum.map(players, fn player ->
        if player.id == player_id do
          GamePlayer.add_answer(player, answer)
        else
          player
        end
      end)

    %Game{game | players: players}
  end
end
