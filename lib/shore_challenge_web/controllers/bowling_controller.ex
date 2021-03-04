defmodule ShoreChallengeWeb.BowlingController do
  use Phoenix.Controller

  alias ShoreChallenge.GamePool
  alias ShoreChallenge.Bowling

  import Plug.Conn

  # TODO: refactoring here is required:
  # - implement Fallback controller
  # - more ideomatic (plug like) conn transformation

  def new(%Plug.Conn{} = conn, _params) do
    {:ok, pid} = ShoreChallenge.Bowling.start_link([])

    game_id = GamePool.get(pid)

    conn
    |> send_resp(200, game_id)
  end

  def score(%Plug.Conn{} = conn, %{"game_id" => game_id}) do
    case GamePool.get(game_id) do
      nil ->
        conn
        |> send_resp(404, "Game #{game_id} not found")

      pid ->
        score = Bowling.score(pid)

        conn
        |> send_resp(200, "#{score}")
    end
  end

  def score(%Plug.Conn{} = conn, _params) do
    conn
    |> invalid_params_resp()
  end

  def roll(%Plug.Conn{} = conn, %{"game_id" => game_id, "score" => score}) do
    case GamePool.get(game_id) do
      nil ->
        conn
        |> send_resp(404, "Game #{game_id} not found")

      pid ->
        case Bowling.add_roll(pid, String.to_integer(score)) do
          {:error, msg} ->
            conn
            |> send_resp(400, msg)

          _ ->
            conn
            |> send_resp(200, Bowling.score(pid) |> Integer.to_string())
        end
    end
  end

  def roll(%Plug.Conn{} = conn, _params) do
    conn
    |> invalid_params_resp()
  end

  defp invalid_params_resp(conn) do
    conn
    |> send_resp(400, "Invalid params")
  end
end
