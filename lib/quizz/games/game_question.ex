defmodule Quizz.Games.GameQuestion do
  use Ecto.Schema

  embedded_schema do
    field :question, :string
    field :options, {:array, :string}
    field :answer, :string
  end
end
