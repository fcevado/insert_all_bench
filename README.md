Explores the proposal in https://groups.google.com/g/elixir-ecto/c/ucMvVCtYubM?pli=1

```elixir
iex> InsertAllBench.insert_all([[id: 1, name: 1]])
# INSERT INTO "users" ("id","name") VALUES ($1,$2) [1, 1]
{7946, {1, nil}}

iex> InsertAllBench.alt_insert_all([[id: 1, name: 1]])
# INSERT INTO "users" ("id","name") (WITH "input" AS (select unnest($1::int[]) as id, unnest($2::int[]) as name) SELECT i0."id", i0."name" FROM "input" AS i0) [[1], [1]]
{3091, {1, nil}}

iex> InsertAllBench.insert_all(Enum.map 1..30000, fn i -> [id: i, name: i] end)
{137528, {30000, nil}}

iex> InsertAllBench.alt_insert_all(Enum.map 1..30000, fn i -> [id: i, name: i] end)
{64984, {30000, nil}}
```
