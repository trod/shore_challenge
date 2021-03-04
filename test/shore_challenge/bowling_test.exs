defmodule ShoreChallenge.BowlingTest do
  use ExUnit.Case

  alias ShoreChallenge.Bowling
  alias ShoreChallenge.GamePool
  alias ShoreChallenge.Game

  test "create a new game and add it to game pool" do
    assert {:ok, pid} = Bowling.start_link([])
    %Game{id: id} = Bowling.info(pid)

    assert GamePool.get(pid) == id
  end

  test "get score of a game without rolls" do
    assert {:ok, pid} = Bowling.start_link([])

    assert Bowling.score(pid) == 0
  end

  test "normal first roll" do
    assert {:ok, pid} = Bowling.start_link([])
    %Game{score: score} = Bowling.add_roll(pid, 3)

    assert Bowling.score(pid) == score
  end

  test "normal second roll" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 3
    second_roll = 5

    Bowling.add_roll(pid, first_roll)
    Bowling.add_roll(pid, second_roll)

    assert Bowling.score(pid) == first_roll + second_roll
  end

  test "0 first roll" do
    assert {:ok, pid} = Bowling.start_link([])
    assert %Game{score: 0} = Bowling.add_roll(pid, 0)

    assert Bowling.score(pid) == 0
  end

  test "creates spare if sum of first and second rolls give 10" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 3
    second_roll = 7

    Bowling.add_roll(pid, first_roll)

    %Game{spare: %ShoreChallenge.Game.Spare{first_score: 0}, frames: []} =
      Bowling.add_roll(pid, second_roll)

    assert Bowling.score(pid) == first_roll + second_roll
  end

  test "creates spare bonus 1" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 3
    second_roll = 7
    third_roll = 5

    Bowling.add_roll(pid, first_roll)
    Bowling.add_roll(pid, second_roll)

    assert %Game{strike: nil, spare: nil, frames: [%ShoreChallenge.Game.Frame{score: 15}]} =
             Bowling.add_roll(pid, third_roll)

    assert Bowling.score(pid) == first_roll + second_roll + third_roll
  end

  test "creates strike if first roll gives 10" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 10

    assert %Game{
             strike: %ShoreChallenge.Game.Strike{first_score: 0, second_score: 0},
             spare: nil,
             score: 10,
             frames: []
           } = Bowling.add_roll(pid, first_roll)

    assert Bowling.score(pid) == first_roll
  end

  test "creates strike bonus 1" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 10
    second_roll = 5

    Bowling.add_roll(pid, first_roll)

    assert %Game{
             strike: %ShoreChallenge.Game.Strike{first_score: second_roll, second_score: 0},
             spare: nil,
             score: 15,
             frames: []
           } = Bowling.add_roll(pid, second_roll)

    assert Bowling.score(pid) == first_roll + second_roll
  end

  test "creates strike bonus 2" do
    assert {:ok, pid} = Bowling.start_link([])
    first_roll = 10
    second_roll = 5
    third_roll = 5

    Bowling.add_roll(pid, first_roll)
    Bowling.add_roll(pid, second_roll)

    assert %Game{
             strike: nil,
             spare: nil,
             score: 0,
             frames: [%ShoreChallenge.Game.Frame{score: 20}]
           } = Bowling.add_roll(pid, third_roll)

    assert Bowling.score(pid) == first_roll + second_roll + third_roll
  end

  test "complete game" do
    assert {:ok, pid} = Bowling.start_link([])

    for i <- 0..30, i > 0, do: Bowling.add_roll(pid, 10)

    assert Bowling.score(pid) == 300
  end

  test "negative roll" do
    assert {:ok, pid} = Bowling.start_link([])
    assert {:error, "Negative roll is invalid"} = Bowling.add_roll(pid, -3)
  end

  test "roll exceeds the limit of ten" do
    assert {:ok, pid} = Bowling.start_link([])
    assert {:error, "Pin count exceeds pins on the lane"} = Bowling.add_roll(pid, 12)
  end

  test "roll when game is over" do
    assert {:ok, pid} = Bowling.start_link([])
    for i <- 0..30, i > 0, do: Bowling.add_roll(pid, 10)

    assert {:error, "Game is over"} = Bowling.add_roll(pid, 5)
  end
end
