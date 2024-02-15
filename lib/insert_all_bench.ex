defmodule InsertAllBench do
  @moduledoc """
  Documentation for `InsertAllBench`.
  """

  import Ecto.Query

  def setup do
    Repo.query!("CREATE TABLE IF NOT EXISTS users (id int, name int)")
    Repo.query!("TRUNCATE TABLE users")
  end

  def insert_all(rows) do
    setup()
    :timer.tc(fn -> Repo.insert_all("users", rows) end)
  end

  def alt_insert_all(rows) do
    setup()

    {ids, names} =
      rows
      |> Enum.map(fn row ->
        [:id, :name]
        |> Enum.map(fn field -> row[field] end)
        |> List.to_tuple()
      end)
      |> Enum.unzip()

    q =
      "input"
      |> with_cte("input",
        as: fragment("select unnest(?::int[]) as id, unnest(?::int[]) as name", ^ids, ^names)
      )
      |> select([i], %{id: i.id, name: i.name})

    :timer.tc(fn -> Repo.insert_all("users", q) end)
  end
end
