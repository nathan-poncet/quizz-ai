defmodule Quizz.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Quizz.Games.{Game, GamePlayer, GameQuestion, GameQuestions}

  embedded_schema do
    field :current_question, :integer, default: 0
    field :difficulty, Ecto.Enum, values: [:easy, :medium, :hard, :genius, :godlike]
    field :nb_questions, :integer

    field :status, Ecto.Enum,
      values: [:lobby, :in_play, :in_play_question_timeout, :finished],
      default: :lobby

    field :time_per_question, :integer, default: 10_000
    field :time_to_answer, :integer, default: 30_000
    field :topic, :string

    embeds_many :players, GamePlayer
    embeds_many :questions, GameQuestion
  end

  @doc """
  Create a new game.
  """
  def register(
        %{id: game_id, topic: topic, difficulty: difficulty, nb_questions: nb_questions} = params
      ) do
    %Game{
      id: game_id,
      topic: topic,
      difficulty: difficulty,
      nb_questions: nb_questions,
      questions: GameQuestions.generate(params)
    }
  end

  @doc """
  Start the game.
  """
  def start(%Game{status: :lobby} = game) do
    :timer.send_after(game.time_per_question, self(), :reveal_responses)
    {:ok, %Game{game | status: :in_play}}
  end

  def start(%Game{}),
    do: {:error, :game_has_already_started}

  @doc """
  Finish the game.
  """
  def finish(%Game{status: :in_play} = game), do: {:ok, %Game{game | status: :finished}}

  def finish(%Game{}),
    do: {:error, :game_is_not_in_play}

  @doc """
  Next question.
  """
  def next_question(
        %Game{
          current_question: current_question,
          players: [owner_player | _],
          questions: questions,
          status: :in_play_question_timeout
        } = game,
        player_id
      )
      when current_question < length(questions) and
             owner_player.id == player_id do
    :timer.send_after(game.time_per_question, self(), :reveal_responses)
    {:ok, %Game{game | current_question: current_question + 1}}
  end

  def next_question(
        %Game{players: [owner_player | _], status: :in_play_question_timeout},
        player_id
      )
      when owner_player.id != player_id,
      do: {:error, :you_are_not_the_owner_of_the_game}

  def next_question(
        %Game{
          current_question: current_question,
          questions: questions,
          status: :in_play_question_timeout
        },
        _player_id
      )
      when current_question >= length(questions),
      do: {:error, :no_more_questions}

  def next_question(%Game{} = _game, _player_id), do: {:error, :game_is_not_in_play}

  @doc """
  Add a player to the game.
  """
  def add_player(%Game{} = game, player_id),
    do: {:ok, %Game{game | players: game.players ++ [%GamePlayer{id: player_id}]}}

  @doc """
  Add an answer for a player to the game.
  """
  def answer(%Game{players: players, status: :in_play} = game, player_id, answer) do
    case Enum.find(players, fn player -> player.id == player_id end) do
      nil ->
        {:error, :player_is_not_in_the_game}

      _ ->
        {:ok, update_answer(game, player_id, answer)}
    end
  end

  def answer(%Game{status: :in_play_question_timeout} = _game, _player_id, _answer),
    do: {:error, :timeout}

  def answer(_game, _player_id, _answer),
    do: {:error, :game_is_not_in_play}

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

  @doc """
  Update the registration game.
  """
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

  @doc """
  Update the game.
  """
  def update_changeset(game, attrs) do
    game
    |> cast(attrs, [
      :time_per_question,
      :time_to_answer
    ])
    |> validate_required([
      :time_per_question,
      :time_to_answer
    ])
    |> validate_number(:time_per_question, greater_than_or_equal_to: 0)
    |> validate_number(:time_to_answer, greater_than_or_equal_to: 0)
  end
end
