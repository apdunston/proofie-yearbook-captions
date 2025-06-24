defmodule Proofie.EnveloopAdapter do
  @moduledoc """
  Enveloop adapter for Swoosh mailer.

  Integrates with Enveloop's API to send transactional emails.
  """

  use Swoosh.Adapter

  alias Swoosh.Email
  require Logger

  @base_url "https://api.enveloop.com"

  @impl Swoosh.Adapter
  def deliver(%Email{} = email, config \\ []) do
    api_key = config[:api_key] || get_api_key()

    if is_nil(api_key) do
      Logger.error("Enveloop API key not configured")
      {:error, "Enveloop API key not configured"}
    else
      send_email(email, api_key)
    end
  end

  defp get_api_key do
    case Application.get_env(:proofie, Proofie.Mailer) do
      nil -> nil
      config -> config[:api_key]
    end
  end

  defp send_email(email, api_key) do
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    # Build simple payload that matches Enveloop's API
    body =
      %{
        "to" => format_recipients(email.to),
        "from" => format_sender(email.from),
        "subject" => email.subject,
        "text" => email.text_body,
        "html" => email.html_body
      }
      |> remove_nil_values()

    case Req.post("#{@base_url}/messages",
           headers: headers,
           json: body
         ) do
      {:ok, %{status: 200, body: response}} ->
        Logger.info("Email sent successfully via Enveloop: #{inspect(response)}")
        {:ok, response}

      {:ok, %{status: status, body: error}} ->
        Logger.error("Enveloop API error #{status}: #{inspect(error)}")
        {:error, "Enveloop API error: #{status}"}

      {:error, reason} ->
        Logger.error("Failed to send email via Enveloop: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp format_recipients(recipients) when is_list(recipients) do
    recipients
    |> Enum.map(&format_single_recipient/1)
    |> Enum.join(",")
  end

  defp format_recipients(recipient), do: format_single_recipient(recipient)

  defp format_single_recipient({email, name}) when is_binary(email) and is_binary(name) do
    "#{name} <#{email}>"
  end

  defp format_single_recipient({email, _}) when is_binary(email) do
    email
  end

  defp format_single_recipient(email) when is_binary(email) do
    email
  end

  defp format_sender({email, name}) when is_binary(email) and is_binary(name) do
    "#{name} <#{email}>"
  end

  defp format_sender({email, _}) when is_binary(email) do
    email
  end

  defp format_sender(email) when is_binary(email) do
    email
  end

  defp remove_nil_values(map) do
    map
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.into(%{})
  end

  @impl Swoosh.Adapter
  def validate_config(config) do
    if config[:api_key] do
      :ok
    else
      {:error, "Enveloop API key is required"}
    end
  end

  @impl Swoosh.Adapter
  def validate_dependency do
    :ok
  end
end
