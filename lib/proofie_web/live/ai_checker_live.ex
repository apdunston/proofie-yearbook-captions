defmodule ProofieWeb.AiCheckerLive do
  use ProofieWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:caption_text, "")
     |> assign(:ai_feedback, nil)
     |> assign(:analyzing, false)
     |> assign(:page_title, "Caption Checker")}
  end

  def handle_event("analyze_caption", %{"caption" => caption}, socket) do
    if String.trim(caption) == "" do
      # Start analysis
      send(self(), {:analyze_with_ai, caption})

      {:noreply,
       socket
       |> assign(:caption_text, caption)
       |> assign(:ai_feedback, nil)
       |> assign(:analyzing, false)}
    else
      # Start analysis
      send(self(), {:analyze_with_ai, caption})

      {:noreply,
       socket
       |> assign(:caption_text, caption)
       |> assign(:analyzing, true)
       |> assign(:ai_feedback, nil)}
    end
  end

  def handle_event("update_caption", %{"caption" => caption}, socket) do
    {:noreply, socket |> assign(:caption_text, caption)}
  end

  def handle_event("clear_caption", _params, socket) do
    {:noreply,
     socket
     |> assign(:caption_text, "")
     |> assign(:ai_feedback, nil)
     |> assign(:analyzing, false)}
  end

  def handle_info({:analyze_with_ai, caption}, socket) do
    # Get the direct AI response text
    feedback = Proofie.OpenAIClient.analyze_caption(caption)

    {:noreply,
     socket
     |> assign(:ai_feedback, feedback)
     |> assign(:analyzing, false)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen p-8 bg-gradient-to-br from-yellow-50 to-blue-100">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="inline-block bg-white p-6 rounded-lg shadow-lg transform rotate-1 border-4 border-yellow-400">
            <h1 class="text-4xl font-bold text-blue-900 mb-2 font-serif">
              🖼️ Caption Checker
            </h1>
            <p class="text-lg text-blue-800">Smart AI-powered style and content analysis</p>
          </div>
        </div>

        <div class="max-w-4xl mx-auto">
          <!-- Input Section -->
          <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 mb-6">
            <h2 class="text-2xl font-bold text-blue-900 mb-4 font-serif">Enter Your Caption</h2>
            <form phx-submit="analyze_caption" phx-change="update_caption">
              <input
                type="text"
                name="caption"
                value={@caption_text}
                placeholder="Type your yearbook caption here and press Enter to analyze..."
                class="w-full p-4 border-2 border-yellow-400 rounded-lg focus:border-yellow-500 focus:ring focus:ring-yellow-200 font-serif text-amber-900 bg-yellow-50"
              />
              <div class="mt-4 flex justify-between items-center">
                <div class="flex gap-2">
                  <button
                    type="submit"
                    disabled={@analyzing or String.trim(@caption_text) == ""}
                    class="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white px-6 py-2 rounded-lg transition-colors font-semibold"
                  >
                    <%= if @analyzing do %>
                      <span class="flex items-center">
                        <svg class="animate-spin h-4 w-4 mr-2" viewBox="0 0 24 24">
                          <circle
                            class="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            stroke-width="4"
                            fill="none"
                          >
                          </circle>
                          <path
                            class="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                          >
                          </path>
                        </svg>
                        Analyzing...
                      </span>
                    <% else %>
                      Analyze with AI
                    <% end %>
                  </button>
                  <button
                    type="button"
                    phx-click="clear_caption"
                    class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors"
                  >
                    Clear
                  </button>
                </div>
                <span class="text-blue-800">
                  {String.length(@caption_text)} characters
                </span>
              </div>
            </form>
          </div>
          
    <!-- Results Section -->
          <%= if @ai_feedback do %>
            <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 mb-6">
              <h2 class="text-2xl font-bold text-blue-900 mb-4 font-serif">AI Analysis Results</h2>

              <div class={[
                "p-6 rounded-lg border-2 text-lg font-serif",
                if String.starts_with?(@ai_feedback, "Pass") do
                  "bg-green-50 border-green-300 text-green-800"
                else
                  "bg-red-50 border-red-300 text-red-800"
                end
              ]}>
                <div class="flex items-start">
                  <span class="text-2xl mr-3">
                    {if String.starts_with?(@ai_feedback, "Pass"), do: "✅", else: "❌"}
                  </span>
                  <div class="flex-1">
                    <p>{@ai_feedback}</p>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @caption_text != "" and @ai_feedback == nil and not @analyzing do %>
            <div class="bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 mb-6">
              <div class="text-center py-8">
                <p class="text-blue-700 text-lg">
                  Click "Analyze with AI" to get intelligent feedback on your caption
                </p>
              </div>
            </div>
          <% end %>
          
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
