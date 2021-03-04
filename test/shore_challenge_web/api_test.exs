defmodule ShoreChallengeWeb.APITest do
  use ShoreChallengeWeb.ConnCase
  alias ShoreChallenge.GamePool

  describe "POST /new" do
    test "creates new game", %{conn: conn} do
      assert %{resp_body: game_uuid, status: 200} =
               conn
               |> post("/api/new")

      refute game_uuid |> GamePool.get() |> is_nil()
    end
  end

  describe "GET /score" do
    test "returns score of an existing game", %{conn: conn} do
      %{resp_body: game_uuid, status: 200} =
        conn
        |> post("/api/new")

      assert %{resp_body: "0", status: 200} =
               conn
               |> put_req_header("content-type", "application/json")
               |> get("/api/score", %{game_id: game_uuid})
    end

    test "returns 404 for non-existing game", %{conn: conn} do
      assert %{resp_body: "Game not_exist not found", status: 404} =
               conn
               |> put_req_header("content-type", "application/json")
               |> get("/api/score", %{game_id: "not_exist"})
    end

    test "returns 400 when required param is missing", %{conn: conn} do
      assert %{resp_body: "Invalid params", status: 400} =
               conn
               |> put_req_header("content-type", "application/json")
               |> get("/api/score", %{})
    end
  end

  describe "POST /roll" do
    test "returns actual score", %{conn: conn} do
      %{resp_body: game_uuid, status: 200} =
        conn
        |> post("/api/new")

      assert %{resp_body: "10", status: 200} =
               conn
               |> put_req_header("content-type", "application/json")
               |> post("/api/roll", %{game_id: game_uuid, score: "10"})
    end

    test "returns 404 for non existing game", %{conn: conn} do
      assert %{resp_body: "Game not_exist not found", status: 404} =
               conn
               |> put_req_header("content-type", "application/json")
               |> post("/api/roll", %{game_id: "not_exist", score: "10"})
    end

    test "returns 400 when required param is missing", %{conn: conn} do
      assert %{resp_body: "Invalid params", status: 400} =
               conn
               |> put_req_header("content-type", "application/json")
               |> post("/api/roll", %{game_id: "not_exist"})
    end

    test "returns 400 required param is invalid", %{conn: conn} do
      %{resp_body: game_uuid, status: 200} =
        conn
        |> post("/api/new")

      assert %{resp_body: "Negative roll is invalid", status: 400} =
               conn
               |> put_req_header("content-type", "application/json")
               |> post("/api/roll", %{game_id: game_uuid, score: "-10"})
    end
  end
end
