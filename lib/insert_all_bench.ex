defmodule InsertAllBench do
  @moduledoc """
  Documentation for `InsertAllBench`.
  """

  import Ecto.Query

  def setup do
    Repo.query!("CREATE TABLE IF NOT EXISTS users (id int, name int)")
    Repo.query!("TRUNCATE TABLE users")
  end

  def all() do
    rows = Enum.map(1..30_000, &%{id: &1, name: &1})
    {t0, _} = ia0(rows)
    {t1, _} = ia1(rows)
    {t2, _} = ia2(rows)
    {t3, _} = ia3(rows)
    {t4, _} = ia4(rows)

    %{
      # usual insert all approach, for reference
      ia0: t0,
      # insert all using unnest with cte, requires explicit casting
      ia1: t1,
      # insert all using jsonb_to_recordset with cte, requires explicit casting
      ia2: t2,
      # raw query using  unnest without cte, doesn't required explicit casting
      ia3: t3,
      # raw query using jsonb_to_recordset without cte, doesn't required explicit casting
      ia4: t4
    }

    # a way to have all approaches execution time seen together
    # a single local execution in my computer had the following times:
    # %{ia0: 388937, ia1: 57431, ia2: 199934, ia3: 1589, ia4: 736}
  end

  def ia0(rows) do
    setup()
    :timer.tc(fn -> Repo.insert_all("users", rows) end)
  end

  def ia1(rows) do
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

  def ia2(rows) do
    setup()

    q =
      "input"
      |> with_cte("input",
        as: fragment("select * from jsonb_to_recordset(?) as i(id int, name int)", ^rows)
      )
      |> select([i], %{id: i.id, name: i.name})

    :timer.tc(fn -> Repo.insert_all("users", q) end)
  end

  def ia3(rows) do
    setup()

    {ids, names} =
      rows
      |> Enum.map(fn row ->
        [:id, :name]
        |> Enum.map(fn field -> row[field] end)
        |> List.to_tuple()
      end)
      |> Enum.unzip()

    q = """
    insert into users (id, name) (select * from unnest($1, $2));
    """

    :timer.tc(fn -> Repo.query(q, [ids, names]) end)
  end

  def ia4(rows) do
    setup()

    rows = Enum.map(rows, &Jason.encode!(&1))

    q = """
    insert into users (id, name) (select * from jsonb_to_recordset($1));
    """

    :timer.tc(fn -> Repo.query(q, [rows]) end)
  end
end
