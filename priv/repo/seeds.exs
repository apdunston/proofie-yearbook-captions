# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Proofie.Repo.insert!(%Proofie.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create a test user for development
{:ok, user} =
  Proofie.Accounts.register_user(%{email: "admin@example.com", password: "password123456"})

{:ok, _user, _expired_tokens} =
  Proofie.Accounts.update_user_password(user, %{password: "password123456"})

IO.puts("Created test user: admin@example.com / password123456")
