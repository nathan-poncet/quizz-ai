defmodule Quizz.Games.ServerTest do
  alias Quizz.Games.GamePlayer
  alias Quizz.Games.GameQuestions
  alias Quizz.Games.Game
  alias Quizz.Games.GameQuestion
  alias Quizz.Games.Server

  use ExUnit.Case, async: true
  import Mock

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

  test "are permanent workers" do
    assert Supervisor.child_spec(Server, []).restart == :permanent
  end

  test "start_link" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    assert pid == Server.whereis("game_id")
  end

  test "child_spec" do
    assert Server.child_spec("game_id") == %{
             id: Quizz.Games.Server,
             start: {Quizz.Games.Server, :start_link, ["game_id"]},
             type: :worker,
             restart: :permanent
           }
  end

  test "init" do
    {:ok, game} =
      Server.init(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    expected_game = %Game{
      current_question: nil,
      difficulty: :easy,
      id: "game_id",
      nb_questions: 2,
      players: [],
      questions: [
        %GameQuestion{},
        %GameQuestion{}
      ],
      status: :lobby,
      topic: "Maths"
    }

    assert expected_game == game
  end

  test "where is" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    assert pid == Server.whereis("game_id")
  end

  test "start" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    assert {:ok, game} = Server.start(pid)
    assert game.status == :in_play
  end

  test "join" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    assert {:ok, game} = Server.join(pid, "player_id", self())
    assert game.players == [%GamePlayer{id: "player_id", answers: []}]
  end

  test "join when game has already started" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    {:ok, _game} = Server.start(pid)

    assert {:error, :game_has_already_started} == Server.join(pid, "player_id", self())
  end

  test "game when game has already started" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    expected_game = %Game{
      current_question: nil,
      difficulty: :easy,
      id: "game_id",
      nb_questions: 2,
      players: [],
      questions: [
        %GameQuestion{},
        %GameQuestion{}
      ],
      status: :lobby,
      topic: "Maths"
    }

    assert expected_game == Server.game(pid)
  end

  test "answer" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    {:ok, _game} = Server.join(pid, "player_id", self())
    {:ok, game} = Server.answer(pid, "player_id", "answer")

    assert [%GamePlayer{id: "player_id", answers: ["answer"]}] == game.players
  end

  test "answer when player is not in the game" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    {:ok, _game} = Server.join(pid, "player_id", self())

    assert {:error, :player_is_not_in_the_game} == Server.answer(pid, "player_id_2", "answer")
  end

  test "answer when game is not in play" do
    {:ok, pid} =
      Server.start_link(
        game_id: "game_id",
        params: %{topic: "Maths", difficulty: :easy, nb_questions: 2}
      )

    assert {:error, :game_is_not_in_play} == Server.answer(pid, "player_id", "answer")
  end
end
