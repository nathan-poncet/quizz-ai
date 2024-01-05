defmodule Quizz.Games.TopicsTest do
  use ExUnit.Case

  alias Quizz.Games.Topics

  test "generate/1 generates a list of topics" do
    gen_topics = Topics.generate(["maths", "history"])

    gen_topics = gen_topics |> Enum.map(fn topic -> topic["title"] end)

    assert gen_topics not in ["maths", "history"]
  end
end
