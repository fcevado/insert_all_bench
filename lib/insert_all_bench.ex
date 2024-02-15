defmodule InsertAllBench do
  @moduledoc """
  Documentation for `InsertAllBench`.
  """

  # import Ecto.Query

  def setup do
    Repo.query!("CREATE TABLE IF NOT EXISTS users (id int, name int)")
    Repo.query!("TRUNCATE TABLE users")
  end

  def run1(rows) do
    setup()
    :timer.tc(fn -> Repo.insert_all("users", rows) end)
  end

  def run2(rows) do
    setup()

    {ids, names} =
      rows
      |> Enum.map(fn row ->
        [:id, :name]
        |> Enum.map(fn field -> row[field] end)
        |> List.to_tuple()
      end)
      |> Enum.unzip()

    # q =
    #   from(i in fragment("unnest(?::int[],?::int[]) AS input(id,name)", ^ids, ^names),
    #     select: %{id: i.id, name: i.name}
    #   )

    # :timer.tc(fn -> Repo.insert_all("users", q) end)

    :timer.tc(fn ->
      Repo.query!("INSERT INTO users(id,name) (SELECT * FROM unnest($1::int[],$2::int[]))", [
        ids,
        names
      ])
    end)
  end
end
