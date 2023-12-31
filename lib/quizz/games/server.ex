defmodule Quizz.Games.Server do
  require Logger
  use GenServer
  alias Quizz.Games.Game

  def start_link(args) do
    Logger.debug("Starting game server.")
    game_id = Keyword.get(args, :game_id)

    GenServer.start_link(__MODULE__, args, name: via_tuple(game_id))
  end

  def child_spec(game_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [game_id]},
      type: :worker,
      restart: :permanent
    }
  end

  def init(init_args) do
    Logger.debug("Initializing game server.")

    game_id = Keyword.get(init_args, :game_id)
    settings = Keyword.get(init_args, :settings)

    {:ok, Game.new(game_id, settings)}
  end

  def whereis(game_id) do
    case Registry.lookup(:game_server_registry, game_id) do
      [] ->
        :undefined

      [{pid, _}] ->
        pid
    end
  end

  # Client

  def start(game_server),
    do: GenServer.call(game_server, :start)

  def join(game_server, player_id, channel_pid),
    do: GenServer.call(game_server, {:join, player_id, channel_pid})

  def game(game_server), do: GenServer.call(game_server, :game)

  def answer(game_server, player_id, answer),
    do: GenServer.call(game_server, {:answer, player_id, answer})

  # Server

  def handle_call(:start, _from, game) do
    case Game.start(game) do
      {:ok, game} ->
        {:reply, {:ok, game}, game}

      {:error, reason} ->
        {:reply, {:error, reason}, game}
    end
  end

  def handle_call({:join, player_id, channel_pid}, _from, game) do
    case Game.add_player(game, player_id) do
      {:ok, game} ->
        Process.flag(:trap_exit, true)
        Process.monitor(channel_pid)

        {:reply, {:ok, game}, game}

      {:error, reason} ->
        {:reply, {:error, reason}, game}
    end
  end

  def handle_call(:game, _from, game), do: {:reply, game, game}

  def handle_call({:answer, player_id, answer}, _from, game) do
    game = Game.answer(game, player_id, answer)
    {:reply, game, game}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _info} = message, game) do
    Logger.info("Handling disconnected ref in Game #{game.id}")
    Logger.info("#{inspect(message)}")

    # {:stop, :normal, game}
    {:noreply, game}
  end

  defp via_tuple(id), do: {:via, Registry, {:game_server_registry, id}}
end
