defmodule Quizz.Games.GamePlayer do
  alias Quizz.Games.GamePlayer
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :answers, {:array, :string}, default: []
  end

  def add_answer(%GamePlayer{} = player, answer),
    do: %GamePlayer{player | answers: player.answers ++ [answer]}

  def changeset(%GamePlayer{} = player, attrs) do
    player
    |> cast(attrs, [:user_id, :answers])
    |> validate_required([:user_id])
  end
end
