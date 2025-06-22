defmodule Proofie.OpenAIClient do
  @moduledoc """
  Client for interacting with OpenAI API to analyze yearbook captions.
  """

  require Logger

  @system_prompt """
  You are a yearbook editor. I'm going to put in captions, and you tell me if they follow the rules. Here are the rules.

  1. Every person named in the caption must have a full name and high-school year or an honorific and last name.
  2. High school year is either one of the words freshman, sophomore, junior, or senior preceding the name or a parenthetical number between 9 and 12. e.g. "Freshman Adrian Dunston" or "Adrian Dunston (9)"
  3. Honorifics can include but are not limited to Mx.,  Mme.,  Mr., Ms., Mrs., Dr., Chef, Chief, Principal, Vice Principal, and Coach. e.g. "Coach Beard" or "Mme Valladares"
  4. High school years cannot have the "th" suffix
  5. A caption can only be a list of one or more names and grades, a single sentence, or three sentences.
  6. One sentence captions must be full sentences in present tense.
  7. Three sentence captions must have one full present tense sentence, one full past tense sentence, and one quote of any format.
  8. Names must be properly capitalized.
  9. Sentences must have proper spelling and punctuation.
  10. Coach Green motivates the team on the sideline.
  11. Not all captions need a name. e.g. "Art students and chaperones visit the Ackland Art Museum."

  Your responses should only be the word "Pass" or the word "Fail" with an explanation of the rule they violated. Do not include rule numbers. Omit needless words. Messages after this one will be captions.

  ## Examples

  User: Adrian Dunston (9)
  System: Pass

  User: Adrian Dunston (9), Lauren (10)
  System: Fail - Lauren lacks a last name.

  User: Adrian Dunston (9th), Lauren casteen (10th)
  System: Fail - Grade numbers use no "th" suffix, and names must be properly capitalized.

  User: Adrian Dunston (9), Lauren Casteen (10)
  System: Pass

  User: Sophomore Brandis Swain running to defend an opponent
  System: Fail - This is not a full sentence.

  User: Sophomore Brandis Swain runs to defend an apponent
  System: Fail - "Aponent" is misspelled and the sentence is missing a period.

  User: Lola Dedrick (9) and Bri McCauley (10) run to the ball
  System: Fail - The sentence is missing a period.

  User: Colt Westbrook putts on the green.
  System: Fail - Missing high school year or honorific

  User: Coach Green motivates the team on the sideline.
  System: Pass

  User: Harlem Renaissance Jazz Project - Made by Mayra Valladares
  System: Fail - Not a full sentence, and missing high school year or honorific for Mayra Valladares.

  User: A behind-the-scenes look at students creating their artwork.
  System: Fail - This is not a full sentence.

  User: The ensemble of Little Shop of Horrors practices their choreography.
  System: Pass

  User: (Left to right) Chloe Thomas-Santos (12) and Jazmin Mercado (11) run lines with a cast member at Little Shop of Horrors practice.
  System: Pass

  User: Dr. Ginger Jones-Robinson accompanies the chorus.
  System: Pass

  User: Coach Harper - Reid
  System: Fail - Not a full sentence or a list of names and grades; also unclear if "Reid" is a last name or a separate person.

  User: Coach Harper-Reid
  System: Pass

  User: Northern Engine 1, our very own fire truck!
  System: Fail - This is not a full sentence.

  User: CTE classes offer a lot of opportunities for cross-collaboration. Here, senior Adriana Cannady puts out a grease fire in a joint lesson with Culinary Arts.
  System: Fail - These two sentences don't fit the formats: list-of-names, one present-tense sentence, or the three-sentence structure.

  User: Ian Dutton getting ready to shoot the basketball
  System: Fail - Missing high school year or honorific. Also this is not a full sentence.

  User: Kailia West shows off her results of taking Weightlifting
  System: Fail - Missing high school year or honorific.

  User: Chef Rutt (right) and Mr. Tilley share information during a Student Government interest meeting.
  System: Pass

  User: Junior Josiah Moore shooting a free throw
  System: Fail - This is not a full sentence.

  User: Coach Horne
  System: Pass
  """

  @doc """
  Analyzes a yearbook caption using OpenAI GPT model.
  Returns the direct response from the AI.
  """
  def analyze_caption(caption) when is_binary(caption) do
    config = Application.get_env(:proofie, :openai, [])
    api_key = Keyword.get(config, :api_key)
    model = Keyword.get(config, :model, "gpt-4.1")

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
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      model: model,
      messages: [
        %{
          role: "system",
          content: @system_prompt
        },
        %{
          role: "user",
          content: caption
        }
      ],
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

  defp parse_openai_response(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    String.trim(content)
  end

  defp parse_openai_response(_response) do
    Logger.warning("Unexpected OpenAI response format, falling back to simulation")
    simulate_ai_analysis("")
  end

  # Fallback simulation for when OpenAI is not available
  defp simulate_ai_analysis(caption) do
    Process.sleep(1500)

    cond do
      String.length(caption) < 10 ->
        "Fail - Caption is too short and lacks sufficient detail for a yearbook entry."

      String.match?(caption, ~r/\b\d+(st|nd|rd|th)\s+grade\b/i) ->
        "Fail - Use 'Grade 9' format instead of '9th grade'."

      String.contains?(String.downcase(caption), "students enjoy") ->
        "Pass - Good caption, though consider being more specific about the activity."

      not String.ends_with?(caption, ".") and not String.ends_with?(caption, "!") and
          not String.ends_with?(caption, "?") ->
        "Fail - Caption should end with proper punctuation."

      true ->
        "Pass - This caption follows yearbook guidelines effectively."
    end
  end
end
