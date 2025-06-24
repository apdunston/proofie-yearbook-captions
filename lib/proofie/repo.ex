defmodule Proofie.Repo do
  use Ecto.Repo,
    otp_app: :proofie,
    adapter: Ecto.Adapters.SQLite3
end
