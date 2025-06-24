defmodule Proofie.EnveloopAdapter do
  @moduledoc """
  Enveloop adapter for Swoosh mailer.

  Integrates with Enveloop's API to send transactional emails.
  """

  use Swoosh.Adapter

  alias Swoosh.Email
  require Logger

  @base_url "https://api.enveloop.com"
  @api_version "v1"

  @impl Swoosh.Adapter
  def deliver(%Email{} = email, config \\ []) do
    api_key = config[:api_key] || Application.get_env(:proofie, :enveloop)[:api_key]
    template_id = config[:template_id] || get_template_id(email)

    if is_nil(api_key) do
      Logger.error("Enveloop API key not configured")
      {:error, "Enveloop API key not configured"}
    else
      send_email(email, api_key, template_id)
    end
  end

  defp send_email(email, api_key, template_id) do
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      template_id: template_id,
      to: build_recipients(email.to),
      from: build_sender(email.from),
      variables: build_variables(email)
    }

    case Req.post("#{@base_url}/#{@api_version}/messages",
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

  defp build_recipients(recipients) when is_list(recipients) do
    Enum.map(recipients, &build_recipient/1)
  end

  defp build_recipients(recipient), do: [build_recipient(recipient)]

  defp build_recipient({email, name}) when is_binary(email) and is_binary(name) do
    %{email: email, name: name}
  end

  defp build_recipient({email, _}) when is_binary(email) do
    %{email: email}
  end

  defp build_recipient(email) when is_binary(email) do
    %{email: email}
  end

  defp build_sender({email, name}) when is_binary(email) and is_binary(name) do
    %{email: email, name: name}
  end

  defp build_sender({email, _}) when is_binary(email) do
    %{email: email}
  end

  defp build_sender(email) when is_binary(email) do
    %{email: email}
  end

  defp build_variables(email) do
    %{
      subject: email.subject,
      html_body: email.html_body,
      text_body: email.text_body
    }
    |> add_custom_variables(email)
  end

  defp add_custom_variables(variables, email) do
    case Map.get(email.private, :enveloop_variables) do
      nil -> variables
      custom_vars when is_map(custom_vars) -> Map.merge(variables, custom_vars)
      _ -> variables
    end
  end

  defp get_template_id(email) do
    # Check if template_id is set in email private data
    case Map.get(email.private, :enveloop_template_id) do
      nil -> Application.get_env(:proofie, :enveloop)[:default_template_id]
      template_id -> template_id
    end
  end
end
