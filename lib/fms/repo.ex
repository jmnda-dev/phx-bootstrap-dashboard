defmodule Fms.Repo do
  use Ecto.Repo,
    otp_app: :fms,
    adapter: Ecto.Adapters.Postgres
end
