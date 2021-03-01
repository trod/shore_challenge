defmodule ShoreChallenge.Repo do
  use Ecto.Repo,
    otp_app: :shore_challenge,
    adapter: Ecto.Adapters.Postgres
end
