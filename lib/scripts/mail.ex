defmodule Proofie.Mail do
    import Swoosh.Email

    def send(email_address) do
        new()
        |> to({email_address, "Adrian"})
        |> from({"adrian@x-omega.com", "Proofie"})
        |> assign(:template, "magic-link")
        |> put_private(:template_variables, %{
            "account_url" => "https://example.com/magic-link"
        })
        |> Proofie.Mailer.deliver()
    end
end
