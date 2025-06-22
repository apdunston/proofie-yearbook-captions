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

    # Check caption structure (rule 5)
    errors = errors ++ check_caption_structure(caption)

    # Check names and grades (rules 1, 2, 3, 4, 8)
    errors = errors ++ check_names_and_grades(caption)

    # Check sentence tense and structure (rules 6, 7)
    errors = errors ++ check_sentence_structure(caption)

    # Check spelling and punctuation (rule 9)
    errors = errors ++ check_spelling_and_punctuation(caption)

    errors
  end

  defp check_caption_structure(caption) do
    # Split into sentences
    sentences =
      caption
      |> String.split(~r/[.!?]+/)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    cond do
      # Check if it's a list of names (comma-separated)
      String.contains?(caption, ",") and not String.contains?(caption, ".") ->
        []

      # Single sentence
      length(sentences) == 1 ->
        []

      # Three sentences
      length(sentences) == 3 ->
        []

      # Invalid structure
      length(sentences) == 2 or length(sentences) > 3 ->
        [
          %{
            type: :structure,
            message: "Caption must be either a list of names, one sentence, or three sentences",
            severity: :error
          }
        ]

      true ->
        []
    end
  end

  defp check_names_and_grades(caption) do
    errors = []

    # Check for "th" suffix in grades (rule 4)
    errors =
      if String.match?(caption, ~r/\b(9th|10th|11th|12th)\b/) do
        errors ++
          [
            %{
              type: :grade_format,
              message:
                "High school years cannot have 'th' suffix. Use (9), (10), (11), (12) or freshman, sophomore, junior, senior",
              severity: :error
            }
          ]
      else
        errors
      end

    # Check for proper name capitalization (rule 8)
    words = String.split(caption, ~r/\s+/)
    name_pattern = ~r/^[A-Z][a-z]+$/

    # Look for potential names (capitalized words not at sentence start)
    potential_names =
      words
      |> Enum.with_index()
      |> Enum.filter(fn {word, index} ->
        # Skip first word of sentences and common non-name words
        not (index == 0 or word in ~w(The A An And Or But For Of In On At To From With By)) and
          String.match?(word, ~r/^[A-Z]/)
      end)
      |> Enum.map(fn {word, _} -> word end)

    # Check if names follow proper capitalization
    errors =
      Enum.reduce(potential_names, errors, fn name, acc ->
        if not String.match?(name, name_pattern) and String.length(name) > 1 do
          acc ++
            [
              %{
                type: :capitalization,
                message: "Names must be properly capitalized: #{name}",
                severity: :warning
              }
            ]
        else
          acc
        end
      end)

    # Check for proper grade formatting (rules 2, 3)
    grade_words = ~w(freshman sophomore junior senior)
    honorifics = ~w(Mx Mme Mr Ms Mrs Dr Chef Chief Principal Coach)

    # Look for parenthetical grades
    parenthetical_grades = Regex.scan(~r/\((\d+)\)/, caption)

    errors =
      Enum.reduce(parenthetical_grades, errors, fn [_, grade], acc ->
        grade_num = String.to_integer(grade)

        if grade_num < 9 or grade_num > 12 do
          acc ++
            [
              %{
                type: :grade_format,
                message: "Grade numbers must be between 9 and 12: (#{grade})",
                severity: :error
              }
            ]
        else
          acc
        end
      end)

    errors
  end

  defp check_sentence_structure(caption) do
    errors = []

    sentences =
      caption
      |> String.split(~r/[.!?]+/)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    case length(sentences) do
      1 ->
        # Single sentence must be present tense (rule 6)
        sentence = hd(sentences)

        if not is_present_tense?(sentence) do
          errors ++
            [
              %{
                type: :tense,
                message: "Single sentence captions must be in present tense",
                severity: :warning
              }
            ]
        else
          errors
        end

      3 ->
        # Three sentences: present, past, quote (rule 7)
        [first, second, third] = sentences

        errors =
          if not is_present_tense?(first) do
            errors ++
              [
                %{
                  type: :tense,
                  message: "First sentence must be in present tense",
                  severity: :warning
                }
              ]
          else
            errors
          end

        errors =
          if not is_past_tense?(second) do
            errors ++
              [
                %{
                  type: :tense,
                  message: "Second sentence must be in past tense",
                  severity: :warning
                }
              ]
          else
            errors
          end

        errors =
          if not is_quote?(third) do
            errors ++
              [
                %{
                  type: :format,
                  message: "Third sentence should be a quote",
                  severity: :suggestion
                }
              ]
          else
            errors
          end

        errors

      _ ->
        errors
    end
  end

  defp check_spelling_and_punctuation(caption) do
    errors = []

    # Check for proper punctuation at end
    errors =
      if not String.match?(caption, ~r/[.!?]$/) do
        errors ++
          [
            %{
              type: :punctuation,
              message: "Caption must end with proper punctuation",
              severity: :error
            }
          ]
      else
        errors
      end

    # Check for double spaces
    errors =
      if String.contains?(caption, "  ") do
        errors ++
          [
            %{
              type: :spacing,
              message: "Remove extra spaces between words",
              severity: :warning
            }
          ]
      else
        errors
      end

    # Check for missing spaces after punctuation
    errors =
      if String.match?(caption, ~r/[.!?][A-Z]/) do
        errors ++
          [
            %{
              type: :spacing,
              message: "Add space after punctuation",
              severity: :warning
            }
          ]
      else
        errors
      end

    errors
  end

  # Helper functions for tense detection
  defp is_present_tense?(sentence) do
    # Simple present tense detection - look for common present tense verbs
    present_verbs = ~w(is are am has have do does go goes play plays study studies work works)
    words = String.split(String.downcase(sentence), ~r/\s+/)
    Enum.any?(words, fn word -> word in present_verbs end)
  end

  defp is_past_tense?(sentence) do
    # Simple past tense detection - look for common past tense patterns
    words = String.split(String.downcase(sentence), ~r/\s+/)

    # Check for -ed endings and common irregular past verbs
    past_patterns = ~r/ed$/
    past_verbs = ~w(was were had did went came saw took got made said)

    Enum.any?(words, fn word ->
      String.match?(word, past_patterns) or word in past_verbs
    end)
  end

  defp is_quote?(text) do
    # Check if text contains quotation marks
    String.contains?(text, "\"") or String.contains?(text, "'")
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen p-8 bg-gradient-to-br from-yellow-50 to-blue-100">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="inline-block bg-white p-6 rounded-lg shadow-lg transform -rotate-1 border-4 border-yellow-400">
            <h1 class="text-4xl font-bold text-blue-900 mb-2 font-serif">
              📝 Algorithmic Caption Checker
            </h1>
            <p class="text-lg text-blue-800">Comprehensive yearbook caption rule validation</p>
          </div>
        </div>

        <div class="max-w-4xl mx-auto">
          <!-- Input Section -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 mb-6">
            <h2 class="text-2xl font-bold text-blue-900 mb-4 font-serif">Enter Your Caption</h2>
            <form phx-change="validate_caption">
              <input
                type="text"
                name="caption"
                value={@caption_text}
                placeholder="Enter your yearbook caption here..."
                class="w-full p-4 border-2 border-yellow-400 rounded-lg focus:border-yellow-500 focus:ring focus:ring-yellow-200 font-serif text-amber-900 bg-yellow-50"
              />
            </form>
            <div class="mt-4 flex justify-between">
              <button
                phx-click="clear_caption"
                class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors"
              >
                Clear
              </button>
              <span class="text-blue-800">
                {String.length(@caption_text)} characters
              </span>
            </div>
          </div>
          
    <!-- Rules Reference -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 mb-6">
            <h3 class="text-xl font-bold text-blue-900 mb-3 font-serif">Yearbook Caption Rules</h3>
            <div class="text-sm text-blue-800 space-y-1">
              <p><strong>Names:</strong> Full name + grade OR honorific + last name</p>
              <p>
                <strong>Grades:</strong> (9), (10), (11), (12) OR freshman, sophomore, junior, senior
              </p>
              <p><strong>Structure:</strong> List of names, 1 sentence, or 3 sentences</p>
              <p><strong>Single sentence:</strong> Present tense only</p>
              <p><strong>Three sentences:</strong> Present + Past + Quote</p>
            </div>
          </div>
          
    <!-- Results Section -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6">
            <h2 class="text-2xl font-bold text-blue-900 mb-4 font-serif">Analysis Results</h2>

            <%= if @errors == [] and @caption_text != "" do %>
              <div class="bg-green-100 border-2 border-green-300 rounded-lg p-4">
                <div class="flex items-center">
                  <span class="text-2xl mr-2">✅</span>
                  <span class="text-green-800 font-semibold">
                    Perfect! Caption follows all yearbook rules.
                  </span>
                </div>
              </div>
            <% end %>

            <%= if @errors == [] and @caption_text == "" do %>
              <div class="text-blue-700 italic text-center py-8">
                Enter a caption above to validate against yearbook rules
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
              class="bg-yellow-600 hover:bg-yellow-700 text-white px-6 py-3 rounded-lg transition-colors font-semibold"
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
