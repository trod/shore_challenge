defmodule ShoreChallenge.Game do
  defstruct frames: [], score: 0, throw: 1, strike: nil, spare: nil, finished: false

  defmodule Strike do
    defstruct first_score: 0, second_score: 0
  end

  defmodule Spare do
    defstruct first_score: 0
  end

  defmodule Frame do
    defstruct score: 0
  end
end
