defmodule Quizz.Games.ServerSupervisor do
  alias Quizz.Games.Server
  use DynamicSupervisor

  require Logger

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: :game_server_supervisor)
  end

  def start_child(params) do
    Logger.debug("Starting game dynamic server supervisor for game")

    DynamicSupervisor.start_child(
      :game_server_supervisor,
      {Server, params: params}
    )
  end

  def terminate_child(game_server_pid) do
    DynamicSupervisor.terminate_child(:game_server_supervisor, game_server_pid)
  end
end
