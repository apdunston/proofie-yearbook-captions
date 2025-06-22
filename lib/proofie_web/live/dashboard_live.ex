defmodule ProofieWeb.DashboardLive do
  use ProofieWeb, :live_view

  def mount(_params, _session, socket) do
    # Define our available tools and coming soon features
    active_tools = [
      %{
        id: :algorithmic_checker,
        name: "Algorithmic Caption Checker",
        description: "Fast, rules-based detection of common caption errors",
        icon: "📝",
        route: "/tools/algorithmic-checker",
        status: :active
      },
      %{
        id: :ai_checker,
        name: "AI Caption Checker",
        description: "Smart AI-powered style and content analysis",
        icon: "🤖",
        route: "/tools/ai-checker",
        status: :active
      }
    ]

    coming_soon_tools = [
      %{
        id: :photo_organizer,
        name: "Photo Organizer",
        description: "Organize and categorize yearbook photos",
        icon: "📸",
        status: :coming_soon
      },
      %{
        id: :quote_verifier,
        name: "Quote Verifier",
        description: "Verify student quotes and attributions",
        icon: "💬",
        status: :coming_soon
      },
      %{
        id: :style_guide,
        name: "Style Guide Checker",
        description: "Ensure consistent formatting and style",
        icon: "📋",
        status: :coming_soon
      },
      %{
        id: :deadline_tracker,
        name: "Deadline Tracker",
        description: "Track submission deadlines and progress",
        icon: "⏰",
        status: :coming_soon
      }
    ]

    {:ok,
     socket
     |> assign(:active_tools, active_tools)
     |> assign(:coming_soon_tools, coming_soon_tools)
     |> assign(:page_title, "Dashboard")}
  end

  def handle_event("navigate_to_tool", %{"route" => route}, socket) do
    {:noreply, push_navigate(socket, to: route)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen p-8 bg-gradient-to-br from-amber-50 to-orange-100">
        <!-- Header with yearbook aesthetic -->
        <div class="text-center mb-12">
          <div class="inline-block bg-white p-8 rounded-lg shadow-lg transform -rotate-1 border-4 border-amber-200">
            <h1 class="text-5xl font-bold text-amber-800 mb-2 font-serif">Proofie</h1>
            <p class="text-xl text-amber-700 italic">Yearbook Caption Analysis Tools</p>
          </div>
        </div>
        
    <!-- Tool Dashboard -->
        <div class="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          
    <!-- Active Tools -->
          <%= for tool <- @active_tools do %>
            <div
              class="bg-gradient-to-br from-white to-amber-50 border-4 border-amber-300 rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 cursor-pointer"
              phx-click="navigate_to_tool"
              phx-value-route={tool.route}
            >
              <div class="text-center">
                <div class="text-4xl mb-4">{tool.icon}</div>
                <h3 class="text-xl font-bold text-amber-800 mb-2 font-serif">{tool.name}</h3>
                <p class="text-amber-700 mb-4">{tool.description}</p>
                <div class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-semibold">
                  Active
                </div>
              </div>
            </div>
          <% end %>
          
    <!-- Coming Soon Tools -->
          <%= for tool <- @coming_soon_tools do %>
            <div class="bg-gradient-to-br from-gray-100 to-gray-200 border-4 border-gray-300 rounded-xl p-6 shadow-lg opacity-60">
              <div class="text-center">
                <div class="text-4xl mb-4">{tool.icon}</div>
                <h3 class="text-xl font-bold text-gray-600 mb-2 font-serif">{tool.name}</h3>
                <p class="text-gray-500 mb-4">{tool.description}</p>
                <div class="bg-gray-200 text-gray-600 px-3 py-1 rounded-full text-sm font-semibold">
                  Coming Soon
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
