defmodule Lighthouse.Repo do
  use Ecto.Repo,
    otp_app: :lighthouse,
    adapter: Ecto.Adapters.SQLite3
end
