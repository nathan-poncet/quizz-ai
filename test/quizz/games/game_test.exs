defmodule Quizz.Games.GameTest do
  use ExUnit.Case
  import Mock

  alias Quizz.Games.GamePlayer
  alias Quizz.Games.GameQuestions
  alias Quizz.Games.GameQuestion
  alias Quizz.Games.Game

  setup_with_mocks([
    {GameQuestions, [],
     [
       generate: fn %{topic: _, difficulty: _, nb_questions: nb_question} ->
         List.duplicate(%GameQuestion{}, nb_question)
       end
     ]}
  ]) do
    :ok
  end

  test "register" do
    assert %Game{
             id: "game_id",
             topic: "Maths",
             difficulty: :easy,
             nb_questions: 2,
             questions: [%GameQuestion{}, %GameQuestion{}]
           } =
             Game.register(%{id: "game_id", topic: "Maths", difficulty: :easy, nb_questions: 2})
  end

  test "start" do
    game = %Game{status: :lobby, time_per_question: 10_000}
    assert {:ok, %Game{status: :in_play}} = Game.start(game)
  end

  test "start when game is already started" do
    game = %Game{status: :in_play}
    assert {:error, :game_has_already_started} = Game.start(game)
  end

  test "finish" do
    game = %Game{status: :in_play}
    assert {:ok, %Game{status: :finished}} = Game.finish(game)
  end

  test "finish when game is not in play" do
    game = %Game{status: :lobby}
    assert {:error, :game_is_not_in_play} = Game.finish(game)
  end

  test "next_question" do
    game = %Game{
      current_question: 0,
      players: [%GamePlayer{id: "player_id"}],
      questions: [
        %GameQuestion{question: "question 1"},
        %GameQuestion{question: "question 2"}
      ],
      status: :timeout
    }

    assert {:ok, %Game{current_question: 1}} = Game.next_question(game, "player_id")
  end

  test "next_question when game is not in play" do
    game = %Game{current_question: 2, status: :lobby}
    assert {:error, :game_is_not_in_play} = Game.next_question(game, "player_id")
  end

  test "next_question when player is not the owner of the game" do
    game = %Game{current_question: 2, players: [%GamePlayer{id: "player_id"}], status: :timeout}

    assert {:error, :you_are_not_the_owner_of_the_game} =
             Game.next_question(game, "wrong_player_id")
  end

  test "next_question when there is no more questions" do
    game = %Game{current_question: 2, status: :timeout, players: [%GamePlayer{id: "player_id"}]}
    assert {:error, :no_more_questions} = Game.next_question(game, "player_id")
  end

  test "answer" do
    game = %Game{
      current_question: 0,
      players: [%GamePlayer{id: "player_id"}],
      questions: [
        %GameQuestion{question: "question 1", answer: "answer 1"},
        %GameQuestion{question: "question 2", answer: "answer 2"}
      ],
      status: :in_play
    }

    expected_game = %Game{
      game
      | players: [%GamePlayer{id: "player_id", answers: ["answer 1"]}]
    }

    assert {:ok, expected_game} =
             Game.answer(game, "player_id", "answer 1")
  end

  test "answer when game is timeout" do
    game = %Game{
      current_question: 0,
      players: [%GamePlayer{id: "player_id"}],
      questions: [
        %GameQuestion{question: "question 1", answer: "answer 1"},
        %GameQuestion{question: "question 2", answer: "answer 2"}
      ],
      status: :in_play_question_timeout
    }

    expected_game = %Game{
      game
      | players: [%GamePlayer{id: "player_id", answers: ["answer 1"]}]
    }

    assert {:error, :timeout} =
             Game.answer(game, "player_id", "answer 1")
  end

  test "answer when game is not in play" do
    game = %Game{current_question: 0, status: :lobby}
    assert {:error, :game_is_not_in_play} = Game.answer(game, "player_id", "answer 1")
  end

  test "answer when player is not in the game" do
    game = %Game{current_question: 0, players: [%GamePlayer{id: "player_id"}], status: :in_play}

    assert {:error, :player_is_not_in_the_game} =
             Game.answer(game, "wrong_player_id", "answer 1")
  end
end
