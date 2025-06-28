# Email Testing Script for Enveloop Integration
# Run with: mix run test_email.exs

defmodule EmailTester do
  require Logger

  def test_enveloop_email do
    IO.puts("=== Proofie Email Test ===")

    # Check for API keys
    sandbox_key = System.get_env("ENVELOOP_SANDBOX_API_KEY")

    cond do
      sandbox_key ->
        IO.puts("Found sandbox API key: #{String.slice(sandbox_key, 0, 10)}...")
        test_with_key(sandbox_key, "sandbox")

      true ->
        IO.puts("❌ No Enveloop API keys found!")
        IO.puts("Please set ENVELOOP_SANDBOX_API_KEY or ENVELOOP_LIVE_API_KEY")
        :error
    end
  end

  defp test_with_key(api_key, environment) do
    IO.puts("Testing with #{environment} environment...")

    # Test email data
    email_data = %{
      "to" => "test@example.com",
      "from" => "noreply@proofie.app",
      "subject" => "Proofie Email Test - #{String.capitalize(environment)}",
      "text" =>
        "This is a test email from your Proofie app using Enveloop #{environment} environment.",
      "html" =>
        "<h1>Proofie Email Test</h1><p>This is a test email from your Proofie app using Enveloop <strong>#{environment}</strong> environment.</p>"
    }

    # Make direct API call to Enveloop
    url = "https://api.enveloop.com/messages"

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    IO.puts("Sending email to: #{email_data["to"]}")
    IO.puts("From: #{email_data["from"]}")
    IO.puts("Subject: #{email_data["subject"]}")

    case Req.post(url, json: email_data, headers: headers) do
      {:ok, %{status: 200, body: body}} ->
        IO.puts("✅ Email sent successfully!")
        IO.puts("Response: #{inspect(body)}")
        :ok

      {:ok, %{status: status, body: body}} ->
        IO.puts("❌ Email failed with status #{status}")
        IO.puts("Error response: #{inspect(body)}")
        :error

      {:error, reason} ->
        IO.puts("❌ Request failed: #{inspect(reason)}")
        :error
    end
  end
end

# Run the test
EmailTester.test_enveloop_email()
