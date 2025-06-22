defmodule ProofieWeb.DashboardLive do
  use ProofieWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")}
  end

  def handle_event("navigate_to_tool", %{"tool" => tool}, socket) do
    case tool do
      "ai-checker" ->
        {:noreply, push_navigate(socket, to: "/tools/ai-checker")}

      _ ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen p-8 bg-gradient-to-br from-yellow-50 to-blue-100">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="inline-block bg-white p-6 rounded-lg shadow-lg transform -rotate-1 border-4 border-yellow-400">
            <h1 class="text-4xl font-bold text-blue-900 mb-2 font-serif">🐶📷 Proofie Dashboard</h1>
            <p class="text-lg text-blue-800">Your yearbook caption analysis toolkit</p>
          </div>
        </div>

        <div class="max-w-6xl mx-auto">
          <!-- Active Tools -->
          <div class="mb-12">
            <h2 class="text-2xl font-bold text-blue-900 mb-6 text-center font-serif">
              🛠️ Active Tools
            </h2>
            <div class="grid md:grid-cols-1 gap-6 max-w-md mx-auto">
              <!-- Caption Checker -->
              <div class="group bg-white rounded-xl shadow-lg border-4 border-yellow-400 p-6 hover:shadow-xl transition-all duration-300 hover:scale-105 transform hover:-rotate-1">
                <div class="text-center">
                  <div class="text-4xl mb-3">🖼️</div>
                  <h3 class="text-xl font-bold text-blue-900 mb-2 font-serif">Caption Checker</h3>
                  <p class="text-blue-700 mb-4">
                    Intelligent AI-powered analysis for comprehensive caption feedback
                  </p>
                  <button
                    phx-click="navigate_to_tool"
                    phx-value-tool="ai-checker"
                    class="bg-yellow-600 hover:bg-yellow-700 text-white px-6 py-3 rounded-lg transition-colors font-semibold group-hover:bg-yellow-500"
                  >
                    Launch Caption Checker
                  </button>
                </div>
              </div>
            </div>
          </div>
          
    <!-- Coming Soon Tools -->
          <div>
            <h2 class="text-2xl font-bold text-blue-900 mb-6 text-center font-serif">
              🚀 Coming Soon
            </h2>
            <div class="grid md:grid-cols-3 gap-6">
              <!-- Photo Caption Generator -->
              <div class="bg-white rounded-xl shadow-lg border-4 border-gray-300 p-6 opacity-75">
                <div class="text-center">
                  <div class="text-4xl mb-3">📸</div>
                  <h3 class="text-xl font-bold text-gray-600 mb-2 font-serif">
                    Photo Caption Generator
                  </h3>
                  <p class="text-gray-500 mb-4">
                    AI-powered caption suggestions based on photo content
                  </p>
                  <button
                    disabled
                    class="bg-gray-400 text-white px-6 py-3 rounded-lg font-semibold cursor-not-allowed"
                  >
                    Coming Soon
                  </button>
                </div>
              </div>
              <!-- Bulk Caption Processor -->
              <div class="bg-white rounded-xl shadow-lg border-4 border-gray-300 p-6 opacity-75">
                <div class="text-center">
                  <div class="text-4xl mb-3">📋</div>
                  <h3 class="text-xl font-bold text-gray-600 mb-2 font-serif">
                    Bulk Caption Processor
                  </h3>
                  <p class="text-gray-500 mb-4">Process multiple captions at once for efficiency</p>
                  <button
                    disabled
                    class="bg-gray-400 text-white px-6 py-3 rounded-lg font-semibold cursor-not-allowed"
                  >
                    Coming Soon
                  </button>
                </div>
              </div>
              <!-- Style Guide Checker -->
              <div class="bg-white rounded-xl shadow-lg border-4 border-gray-300 p-6 opacity-75">
                <div class="text-center">
                  <div class="text-4xl mb-3">📖</div>
                  <h3 class="text-xl font-bold text-gray-600 mb-2 font-serif">Style Guide Checker</h3>
                  <p class="text-gray-500 mb-4">
                    Ensure consistency with your school's style guide
                  </p>
                  <button
                    disabled
                    class="bg-gray-400 text-white px-6 py-3 rounded-lg font-semibold cursor-not-allowed"
                  >
                    Coming Soon
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
