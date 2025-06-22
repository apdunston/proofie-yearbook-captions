defmodule Proofie.OpenAIClient do
  @moduledoc """
  Client for interacting with OpenAI API to analyze yearbook captions.
  """

  require Logger

  @doc """
  Analyzes a yearbook caption using OpenAI GPT model.
  Returns detailed feedback including score, strengths, suggestions, and improvements.
  """
  def analyze_caption(caption) when is_binary(caption) do
    config = Application.get_env(:proofie, :openai, [])
    api_key = Keyword.get(config, :api_key)
    model = Keyword.get(config, :model, "gpt-3.5-turbo")

    if is_nil(api_key) or api_key == "" do
      Logger.warning("OpenAI API key not configured, falling back to simulation")
      simulate_ai_analysis(caption)
    else
      case make_openai_request(caption, api_key, model) do
        {:ok, response} ->
          parse_openai_response(response)

        {:error, reason} ->
          Logger.error("OpenAI API request failed: #{inspect(reason)}")
          simulate_ai_analysis(caption)
      end
    end
  end

  defp make_openai_request(caption, api_key, model) do
    prompt = build_yearbook_prompt(caption)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      model: model,
      messages: [
        %{
          role: "system",
          content:
            "You are an expert yearbook editor who analyzes captions for quality, style, and yearbook best practices."
        },
        %{
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.3,
      max_tokens: 800
    }

    case Req.post("https://api.openai.com/v1/chat/completions",
           headers: headers,
           json: body
         ) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: error}} ->
        {:error, "API returned #{status}: #{inspect(error)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_yearbook_prompt(caption) do
    """
    Please analyze this yearbook caption for quality and provide detailed feedback:

    Caption: "#{caption}"

    Provide your analysis in this exact JSON format:
    {
      "overall_score": 85,
      "strengths": ["List specific positive aspects"],
      "issues": ["List problems that need fixing"],
      "suggestions": ["List improvement recommendations"],
      "improved_version": "Rewritten version of the caption"
    }

    Focus on:
    - Yearbook style and tone appropriateness
    - Clarity and engagement
    - Proper grammar and punctuation
    - Student name usage (when applicable)
    - Context and descriptive quality
    - Active vs passive voice
    - Length appropriateness

    Score from 1-100 where 90+ is excellent, 70-89 is good, 50-69 needs work, below 50 needs major revision.
    """
  end

  defp parse_openai_response(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    case Jason.decode(content) do
      {:ok, parsed} ->
        %{
          overall_score: Map.get(parsed, "overall_score", 70),
          strengths: Map.get(parsed, "strengths", []),
          issues: Map.get(parsed, "issues", []),
          suggestions: Map.get(parsed, "suggestions", []),
          improved_version: Map.get(parsed, "improved_version", "")
        }

      {:error, _} ->
        Logger.warning("Failed to parse OpenAI JSON response, falling back to simulation")
        simulate_ai_analysis("")
    end
  end

  defp parse_openai_response(_response) do
    Logger.warning("Unexpected OpenAI response format, falling back to simulation")
    simulate_ai_analysis("")
  end

  # Fallback simulation for when OpenAI is not available
  defp simulate_ai_analysis(caption) do
    Process.sleep(1500)

    suggestions = []
    strengths = []
    issues = []

    cond do
      String.length(caption) < 10 ->
        issues = issues ++ ["Caption is quite short - consider adding more descriptive details"]

      String.length(caption) > 200 ->
        issues = issues ++ ["Caption is lengthy - consider condensing for better readability"]

      true ->
        strengths = strengths ++ ["Good caption length for readability"]
    end

    if String.contains?(String.downcase(caption), ~w(is are was were been being)) do
      suggestions =
        suggestions ++ ["Consider using more active voice to make the caption more engaging"]
    else
      strengths = strengths ++ ["Good use of active voice"]
    end

    if String.match?(caption, ~r/\b(students?|people|everyone|they)\b/i) and
         not String.match?(caption, ~r/\b[A-Z][a-z]+ [A-Z][a-z]+\b/) do
      suggestions = suggestions ++ ["Consider including specific student names when possible"]
    end

    if not String.match?(caption, ~r/\b(during|while|at|in|for)\b/i) do
      suggestions =
        suggestions ++
          ["Adding context about when or where this took place could improve the caption"]
    else
      strengths = strengths ++ ["Good contextual information provided"]
    end

    if String.match?(caption, ~r/\b(smil|laugh|enjoy|excit|celebrat|cheer)\b/i) do
      strengths = strengths ++ ["Caption captures the emotional aspect of the moment"]
    else
      suggestions =
        suggestions ++ ["Consider mentioning the mood or emotions visible in the photo"]
    end

    %{
      overall_score: calculate_score(issues, suggestions, strengths),
      strengths: strengths,
      suggestions: suggestions,
      issues: issues,
      improved_version: generate_improved_version(caption)
    }
  end

  defp calculate_score(issues, suggestions, strengths) do
    base_score = 70
    penalty = length(issues) * 15 + length(suggestions) * 5
    bonus = length(strengths) * 10

    max(10, min(100, base_score - penalty + bonus))
  end

  defp generate_improved_version(caption) when caption == "", do: ""

  defp generate_improved_version(caption) do
    improved =
      caption
      |> String.replace(~r/\bstudents?\b/i, "seniors")
      |> String.replace(~r/\bpeople\b/i, "classmates")
      |> String.replace(~r/\bare having fun\b/i, "celebrate together")

    if improved == caption do
      "#{String.trim_trailing(caption, ".")}#{if String.ends_with?(caption, "."), do: "", else: "."}"
    else
      improved
    end
  end
end
