defmodule Quizz.Games.Player do
  alias Quizz.Games.Player

  defstruct id: nil, answers: []

  def add_answer(%Player{} = player, answer),
    do: %Player{player | answers: player.answers ++ [answer]}
end
