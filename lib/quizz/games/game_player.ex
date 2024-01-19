defmodule Quizz.Games.GamePlayer do
  alias Quizz.Games.GamePlayer
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string, default: ""
    field :answers, {:array, :string}, default: []
    field :status, Ecto.Enum, values: [:waiting, :playing], default: :waiting
  end

  def add_answer(%GamePlayer{status: :playing} = player, answer),
    do: {:ok, %GamePlayer{player | answers: player.answers ++ [answer]}}

  def add_answer(%GamePlayer{}, _answer),
    do: {:error, :player_is_not_playing}

  def new do
    %GamePlayer{id: uuid()}
  end

  def registration_changeset(%GamePlayer{} = player, attrs) do
    player
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end

  @id_length 16
  defp uuid do
    @id_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @id_length)
  end
end
