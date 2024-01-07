defmodule Quizz.TestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quizz.Tests` context.
  """

  @doc """
  Generate a test.
  """
  def test_fixture(attrs \\ %{}) do
    {:ok, test} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Quizz.Tests.create_test()

    test
  end
end
