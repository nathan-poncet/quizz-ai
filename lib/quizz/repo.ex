defmodule Quizz.Repo do
  use Ecto.Repo,
    otp_app: :quizz,
    adapter: Ecto.Adapters.Postgres
end
