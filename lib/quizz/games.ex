defmodule Quizz.Games do
  defdelegate create_game(game_id), to: Quizz.Games.Client

  defdelegate delete_game(game_id), to: Quizz.Games.Client

  defdelegate start_game(game_id), to: Quizz.Games.Client

  defdelegate join_game(game_id, player_id, pid), to: Quizz.Games.Client

  defdelegate fetch_game(game_id), to: Quizz.Games.Client

  defdelegate answer(game_id, player_id, answer), to: Quizz.Games.Client
end
