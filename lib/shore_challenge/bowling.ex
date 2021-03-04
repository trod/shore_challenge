defmodule ShoreChallenge.Bowling do
  @moduledoc """
  Internal Bowling game API.
  """

  # TODO: Consider to refactor core logic: Maybe use GenStateMachine:any()
  # https://hexdocs.pm/gen_state_machine/GenStateMachine.html

  alias ShoreChallenge.Game
  alias ShoreChallenge.Game.{Frame, Spare, Strike}

  alias ShoreChallenge.GamePool

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

  def info(pid) do
    GenServer.call(pid, :info)
  end

  # callbacks
  @impl true
  def init(:ok) do
    # TODO: That's definitely an overkill to keep ecto only for uuid generation.
    # Need to find similar but lightweight solution
    game_uuid = Ecto.UUID.generate()
    true = GamePool.put(self(), game_uuid)
    true = GamePool.put(game_uuid, self())

    {:ok, %Game{id: game_uuid}}
  end

  @impl true
  def handle_call(:score, _from, game) do
    {:reply, do_score(game), game}
  end

  @impl true
  def handle_call(:info, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:roll, score}, _from, game) do
    game
    |> roll(score)
    |> case do
      {:error, msg} ->
        {:reply, {:error, msg}, game}

      game ->
        {:reply, game, game}
    end
  end

  @spec roll(any, integer) :: any | String.t()
  defp roll(_game, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  defp roll(_game, roll) when roll > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end

  defp roll(%Game{strike: nil, spare: nil, throw: 2, score: score}, roll)
       when roll + score > 10 do
    {:error, "Sum of first and second roll exceeds 10"}
  end

  # Non-fill ball
  defp roll(%Game{} = game, roll) do
    game
    |> maybe_set_finished()
    |> case do
      %Game{finished: true} -> {:error, "Game is over"}
      _ -> do_roll(game, roll)
    end
  end

  defp do_score(%Game{frames: frames, finished: true}) do
    frames
    |> Enum.map(&Map.get(&1, :score))
    |> Enum.sum()
  end

  defp do_score(%Game{frames: frames, finished: false} = game) do
    completed_frame_score =
      frames
      |> Enum.map(&Map.get(&1, :score))
      |> Enum.sum()

    current_frame_score =
      case game do
        %Game{spare: nil, strike: %Strike{first_score: first_score, second_score: second_score}} ->
          10 + first_score + second_score

        %Game{strike: nil, spare: %Spare{first_score: first_score}} ->
          10 + first_score

        _ ->
          game.score
      end

    completed_frame_score + current_frame_score
  end

  # Strike
  defp do_roll(%Game{throw: 1} = game, 10) do
    %{game | score: 10, throw: 2, strike: %Strike{first_score: 0, second_score: 0}}
  end

  # Strike bonus 1
  defp do_roll(
         %Game{
           strike: %Strike{first_score: 0, second_score: 0},
           throw: 2
         } = game,
         roll
       ) do
    %{game | score: 10 + roll, throw: 3, strike: %Strike{first_score: roll, second_score: 0}}
  end

  # Strike bonus 2
  defp do_roll(
         %Game{
           frames: frames,
           throw: 3,
           strike: %Strike{first_score: score, second_score: 0}
         } = game,
         roll
       ) do
    final_score = 10 + score + roll

    %{game | score: 0, frames: [%Frame{score: final_score} | frames], throw: 1, strike: nil}
  end

  # Spare
  defp do_roll(%Game{score: score, throw: 2} = game, roll)
       when score + roll == 10 do
    %{game | throw: 3, strike: nil, spare: %Spare{first_score: 0}}
  end

  # Spare bonus 1
  defp do_roll(
         %Game{
           frames: frames,
           throw: 3,
           spare: %Spare{first_score: 0}
         } = game,
         roll
       ) do
    final_score = 10 + roll

    %{game | frames: [%Frame{score: final_score} | frames], throw: 1, score: 0, spare: nil}
  end

  # first throw
  defp do_roll(%Game{throw: 1} = game, roll) do
    %{game | score: roll, throw: 2}
  end

  #  second throw
  defp do_roll(%Game{frames: frames, throw: 2, score: score} = game, roll) do
    %{game | frames: [%Frame{score: score + roll} | frames], score: 0, throw: 1}
  end

  defp maybe_set_finished(%Game{frames: frames} = game) do
    frame_count = Enum.count(frames)

    cond do
      frame_count >= 10 -> %{game | finished: true, score: 0}
      frame_count < 10 -> game
    end
  end
end
