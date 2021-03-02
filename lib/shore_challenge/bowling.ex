defmodule ShoreChallenge.Bowling do
  alias ShoreChallenge.Game
  alias ShoreChallenge.Game.{Frame, Spare, Strike}
  alias __MODULE__

  use GenServer
  # Client
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def score(pid) do
    GenServer.call(pid, :score)
  end


  def add_roll(pid, score) do
    GenServer.call(pid, {:roll, score})
  end

  # callbacks
  @impl true
  def init(:ok) do
    {:ok, %Game{}}
  end

  @impl true
  def handle_call(:score, _from, game) do
    {:reply, do_score(game), game}
  end

  @impl true
  def handle_call({:roll, score}, _from, game) do
    game = roll(game, score)
    {:reply, game, game}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """
  @spec roll(any, integer) :: any | String.t()
  def roll(_game, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  def roll(game, roll) when roll > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  # Non-fill ball
  def roll(%Game{frames: frames} = game, roll) do
    case game_finished?(game) do
      true -> {:error, "Game is over"}
      _ -> do_roll(%Game{game | frames: frames}, roll)
    end
  end

  @doc """
    Returns score of the current frame + score of completed frames
  """
  def do_score(%Game{frames: frames} = game) do
    completed_frame_score =
      frames
      |> Enum.map(&Map.get(&1, :score))
      |> Enum.sum()

    current_frame_score =
      case game do
        %Game{strike: %Strike{first_score: first_score, second_score: second_score}} ->
          10 + first_score + second_score

        %Game{spare: %Spare{first_score: first_score}} ->
          10 + first_score

        _ ->
          game.score
      end

    completed_frame_score + current_frame_score
  end

  # Strike
  defp do_roll(%Game{frames: frames, throw: 1}, 10) do
    %Game{frames: frames, throw: 2, score: 10, strike: %Strike{first_score: 0, second_score: 0}}
  end

  # Strike bonus 1
  defp do_roll(
         %Game{frames: frames, throw: 2, strike: %Strike{first_score: 0, second_score: 0}},
         roll
       ) do
    %Game{
      frames: frames,
      throw: 2,
      score: 10 + roll,
      strike: %Strike{first_score: roll, second_score: 0}
    }
  end

  # Strike bonus 2
  defp do_roll(
         %Game{frames: frames, throw: 2, strike: %Strike{first_score: score, second_score: 0}},
         roll
       ) do
    final_score = 10 + score + roll
    %Game{frames: [%Frame{score: final_score} | frames], throw: 1, strike: nil}
  end

  # Spare
  defp do_roll(%Game{score: score, frames: frames, throw: 2}, roll) when score + roll == 10 do
    %Game{frames: frames, throw: 2, spare: %Spare{first_score: 0}}
  end

  # Spare bonus 1
  defp do_roll(%Game{frames: frames, throw: 2, score: score, spare: %Spare{first_score: 0}}, roll) do
    final_score = 10 + roll
    %Game{frames: [%Frame{score: final_score} | frames], throw: 1, spare: nil}
  end

  # Normal first throw
  defp do_roll(%Game{frames: frames, throw: 1}, roll) do
    %Game{frames: frames, score: roll, throw: 2}
  end

  # Normal second throw
  defp do_roll(%Game{frames: frames, throw: 2, score: score}, roll) do
    %Game{frames: [%Frame{score: score + roll} | frames]}
  end

  defp game_finished?(%Game{frames: frames}) do
    frame_count = Enum.count(frames)

    cond do
      frame_count >= 10 -> true
      frame_count < 10 -> false
    end
  end
end
