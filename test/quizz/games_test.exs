defmodule Quizz.GamesTest do
  use ExUnit.Case, async: true

  alias Quizz.Games.Server
  alias Quizz.Games.Game

  test "create_game" do
    assert {:ok, %Game{}} =
             Quizz.Games.create_game(%{
               topic: "Maths",
               difficulty: :easy,
               nb_questions: 2
             })
  end
end
