defmodule Quizz.Games.GameTest do
  use ExUnit.Case

  alias Quizz.Games.Player
  alias Quizz.Games.Question
  alias Quizz.Games.Game

  test "add_player/2 adds a player to the game" do
    game = %Game{id: "123", players: []}

    assert {:ok, %Game{id: "123", players: [%Player{id: "456"}]}} =
             Game.add_player(game, "456")
  end

  test "add_player/2 does not add a player to the game if the game is full" do
    game = %Game{
      id: "123",
      players: [%Player{id: "456"}],
      settings: %{max_players: 1}
    }

    assert {:error, _error} = Game.add_player(game, "456")
  end

  test "add_player/2 does not add a player to the game if the game has started" do
    game = %Game{id: "123", players: [%Player{id: "456"}], status: :in_play}

    assert {:error, _error} = Game.add_player(game, "456")
  end

  test "answer/3 adds an answer to the player" do
    game = %Game{id: "123", players: [%Player{id: "456", answers: []}]}

    assert %Game{id: "123", players: [%Player{id: "456", answers: [1]}]} =
             Game.answer(game, "456", 1)
  end

  test "answer/3 does not add an answer to the player if the player does not exist" do
    game = %Game{id: "123", players: [%Player{id: "456", answers: []}]}

    assert %Game{id: "123", players: [%Player{id: "456", answers: []}]} =
             Game.answer(game, "789", "answer")
  end

  test "start/1 starts the game" do
    game = %Game{
      id: "123",
      players: [%Player{id: "456", answers: []}],
      questions: [%Question{}]
    }

    expected_game = %Game{game | status: :in_play}

    assert {:ok, expected_game} =
             Game.start(game)
  end

  test "start/1 does not start the game if the game has already started" do
    game = %Game{
      id: "123",
      players: [%Player{id: "456", answers: []}],
      questions: [%Question{}],
      status: :in_play
    }

    assert {:error, _error} =
             Game.start(game)
  end

  test "start/1 does not start the game if there are no questions" do
    game = %Game{
      id: "123",
      players: [%Player{id: "456", answers: []}],
      questions: []
    }

    assert {:error, _error} =
             Game.start(game)
  end

  test "generate_questions/1 generates questions" do
    game = %Game{
      id: "123",
      players: [%Player{id: "456", answers: []}],
      settings: %{topic: "math", difficulty: :easy, nb_questions: 1}
    }

    expected_game = %Game{game | questions: [%Question{}]}

    assert expected_game =
             Game.questions_generate(game)
  end
end
