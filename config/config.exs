import Config

config :insert_all_bench, ecto_repos: [Repo]
config :insert_all_bench, Repo, url: "postgres://postgres:postgres@localhost:5432/bench_db"
