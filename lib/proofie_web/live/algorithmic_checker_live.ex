defmodule ProofieWeb.AlgorithmicCheckerLive do
  use ProofieWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:caption_text, "")
     |> assign(:errors, [])
     |> assign(:page_title, "Algorithmic Caption Checker")}
  end

  def handle_event("validate_caption", %{"caption" => caption}, socket) do
    errors = analyze_caption(caption)

    {:noreply,
     socket
     |> assign(:caption_text, caption)
     |> assign(:errors, errors)}
  end

  def handle_event("clear_caption", _params, socket) do
    {:noreply,
     socket
     |> assign(:caption_text, "")
     |> assign(:errors, [])}
  end

  defp analyze_caption(caption) when caption == "", do: []

  defp analyze_caption(caption) do
    errors = []

    # Check for common capitalization issues
    errors = errors ++ check_capitalization(caption)

    # Check for punctuation issues
    errors = errors ++ check_punctuation(caption)

    # Check for common yearbook mistakes
    errors = errors ++ check_yearbook_specifics(caption)

    # Check for redundant words
    errors = errors ++ check_redundancy(caption)

    errors
  end

  defp check_capitalization(caption) do
    errors = []

    # Check if first letter is capitalized
    errors =
      if String.match?(caption, ~r/^[a-z]/) do
        errors ++
          [
            %{
              type: :capitalization,
              message: "Caption should start with a capital letter",
              severity: :error
            }
          ]
      else
        errors
      end

    # Check for proper nouns that should be capitalized (months, common names)
    months =
      ~w(january february march april may june july august september october november december)

    errors =
      Enum.reduce(months, errors, fn month, acc ->
        if String.contains?(String.downcase(caption), month) and
             not String.contains?(caption, String.capitalize(month)) do
          acc ++
            [
              %{
                type: :capitalization,
                message: "Month names should be capitalized: #{String.capitalize(month)}",
                severity: :warning
              }
            ]
        else
          acc
        end
      end)

    errors
  end

  defp check_punctuation(caption) do
    errors = []

    # Check for missing period at end
    errors =
      if not String.ends_with?(caption, ".") and not String.ends_with?(caption, "!") and
           not String.ends_with?(caption, "?") do
        errors ++
          [
            %{
              type: :punctuation,
              message: "Caption should end with proper punctuation",
              severity: :warning
            }
          ]
      else
        errors
      end

    # Check for double spaces
    errors =
      if String.contains?(caption, "  ") do
        errors ++
          [%{type: :spacing, message: "Remove extra spaces between words", severity: :warning}]
      else
        errors
      end

    errors
  end

  defp check_yearbook_specifics(caption) do
    errors = []

    # Check for grade levels formatting
    errors =
      if String.match?(caption, ~r/\b\d+(st|nd|rd|th)\s+grade\b/i) do
        errors ++
          [
            %{
              type: :format,
              message: "Use 'Grade 9' format instead of '9th grade'",
              severity: :suggestion
            }
          ]
      else
        errors
      end

    # Check for class year formatting
    errors =
      if String.match?(caption, ~r/class\s+of\s+'\d{2}/i) do
        errors ++
          [
            %{
              type: :format,
              message: "Use full year format: 'Class of 2024' instead of 'Class of '24'",
              severity: :suggestion
            }
          ]
      else
        errors
      end

    errors
  end

  defp check_redundancy(caption) do
    errors = []

    # Check for redundant phrases
    redundant_phrases = ["students enjoy", "having fun", "are pictured"]

    errors =
      Enum.reduce(redundant_phrases, errors, fn phrase, acc ->
        if String.contains?(String.downcase(caption), phrase) do
          acc ++
            [
              %{
                type: :style,
                message: "Consider removing redundant phrase: '#{phrase}'",
                severity: :suggestion
              }
            ]
        else
          acc
        end
      end)

    errors
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen p-8 bg-gradient-to-br from-amber-50 to-orange-100">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="inline-block bg-white p-6 rounded-lg shadow-lg transform -rotate-1 border-4 border-amber-200">
            <h1 class="text-4xl font-bold text-amber-800 mb-2 font-serif">
              📝 Algorithmic Caption Checker
            </h1>
            <p class="text-lg text-amber-700">Fast, rules-based detection of common caption errors</p>
          </div>
        </div>

        <div class="max-w-4xl mx-auto">
          <!-- Input Section -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-amber-200 p-6 mb-6">
            <h2 class="text-2xl font-bold text-amber-800 mb-4 font-serif">Enter Your Caption</h2>
            <form phx-change="validate_caption">
              <textarea
                name="caption"
                value={@caption_text}
                placeholder="Paste your yearbook caption here for analysis..."
                class="w-full h-32 p-4 border-2 border-amber-200 rounded-lg focus:border-amber-400 focus:ring focus:ring-amber-200 resize-none font-serif text-amber-900 bg-amber-50"
              ></textarea>
            </form>
            <div class="mt-4 flex justify-between">
              <button
                phx-click="clear_caption"
                class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors"
              >
                Clear
              </button>
              <span class="text-amber-700">
                {String.length(@caption_text)} characters
              </span>
            </div>
          </div>
          
    <!-- Results Section -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-amber-200 p-6">
            <h2 class="text-2xl font-bold text-amber-800 mb-4 font-serif">Analysis Results</h2>

            <%= if @errors == [] and @caption_text != "" do %>
              <div class="bg-green-100 border-2 border-green-300 rounded-lg p-4">
                <div class="flex items-center">
                  <span class="text-2xl mr-2">✅</span>
                  <span class="text-green-800 font-semibold">Great job! No issues detected.</span>
                </div>
              </div>
            <% end %>

            <%= if @errors == [] and @caption_text == "" do %>
              <div class="text-amber-600 italic text-center py-8">
                Enter a caption above to see analysis results
              </div>
            <% end %>

            <%= for error <- @errors do %>
              <div class={[
                "mb-3 p-4 rounded-lg border-2",
                case error.severity do
                  :error -> "bg-red-100 border-red-300"
                  :warning -> "bg-yellow-100 border-yellow-300"
                  :suggestion -> "bg-blue-100 border-blue-300"
                end
              ]}>
                <div class="flex items-start">
                  <span class="text-xl mr-3">
                    {case error.severity do
                      :error -> "❌"
                      :warning -> "⚠️"
                      :suggestion -> "💡"
                    end}
                  </span>
                  <div>
                    <span class={[
                      "font-semibold text-sm uppercase tracking-wide mr-2",
                      case error.severity do
                        :error -> "text-red-700"
                        :warning -> "text-yellow-700"
                        :suggestion -> "text-blue-700"
                      end
                    ]}>
                      {error.type}
                    </span>
                    <p class={[
                      case error.severity do
                        :error -> "text-red-800"
                        :warning -> "text-yellow-800"
                        :suggestion -> "text-blue-800"
                      end
                    ]}>
                      {error.message}
                    </p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
          
    <!-- Navigation -->
          <div class="text-center mt-8">
            <.link
              navigate="/"
              class="bg-amber-600 hover:bg-amber-700 text-white px-6 py-3 rounded-lg transition-colors font-semibold"
            >
              ← Back to Dashboard
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
