defmodule Proofie.Accounts.UserNotifier do
  import Swoosh.Email

  alias Proofie.Mailer
  alias Proofie.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Proofie", "adrian@x-omega.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    email =
      new()
      |> to(user.email)
      |> from({"Proofie", "adrian@x-omega.com"})
      |> subject("Proofie Magic Link")
      |> assign(:template, "magic-link")
      |> assign(:url, url)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp deliver_confirmation_instructions(user, url) do
    email =
      new()
      |> to(user.email)
      |> from({"Proofie", "adrian@x-omega.com"})
      |> subject("Proofie Email Confirmation")
      |> assign(:template, "confirm-account")
      |> assign(:url, url)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
