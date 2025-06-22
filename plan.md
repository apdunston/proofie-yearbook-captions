# Proofie - Yearbook Caption Analysis Tools

## Project Overview
Proofie is a yearbook-themed web application that helps editors detect and fix problems in yearbook captions using both algorithmic and AI-powered analysis.

## Detailed Plan
- [x] Generate Phoenix LiveView project called `proofie` with SQLite database
- [x] Add user authentication system with phx.gen.auth (email/password/reset)
- [x] Start server and create detailed plan
- [ ] Replace home page with yearbook-themed static mockup showing our vision
- [ ] Create main dashboard with tool tiles:
  - Active tools: Algorithmic Caption Checker, AI Caption Checker
  - Coming Soon tiles: Photo Organizer, Quote Verifier, Style Guide Checker, Deadline Tracker
  - User accounts section access
- [ ] Implement Algorithmic Caption Checker tool:
  - Rules-based detection for common caption errors
  - Check capitalization, punctuation, common yearbook mistakes
  - Real-time feedback as users type
- [ ] Implement AI Caption Checker tool:
  - Integration with AI service for intelligent error detection
  - Smart suggestions for style and content improvements
  - Contextual yearbook-specific recommendations
- [ ] Create user accounts management section:
  - Profile settings, password changes
  - Usage statistics and tool history
- [ ] Design yearbook-themed layouts:
  - Update root.html.heex with yearbook aesthetics (photo frames, school colors)
  - Update <Layouts.app> to match nostalgic yearbook design
  - Remove default Phoenix elements, force light theme
- [ ] Update router to replace placeholder home route with dashboard
- [ ] Test final application with caption analysis tools

## Key Features
- **Tool Dashboard**: Clean tile-based interface showing available and coming-soon tools
- **Algorithmic Detection**: Fast, rules-based caption error detection
- **AI-Powered Analysis**: Smart, contextual caption improvement suggestions  
- **User Authentication**: Full account system with secure login and password reset
- **Yearbook Theme**: Nostalgic design with photo frames, scrapbook elements, school colors
- **Expandable Architecture**: Ready for future yearbook editing tools

## Technical Stack
- Phoenix LiveView for real-time interactions
- User authentication with phx.gen.auth
- SQLite database for user data and analysis results
- Tailwind CSS with yearbook-themed custom styling
- AI integration for smart caption analysis
