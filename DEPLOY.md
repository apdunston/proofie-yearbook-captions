# 🚀 Proofie Deployment Guide

## 📦 Getting Started Locally

### 1. Download & Extract
```bash
# Extract the project archive
tar -xzf proofie-complete.tar.gz
cd proofie
```

### 2. Install Dependencies
```bash
# Install Elixir dependencies
mix deps.get

# Install and setup database
mix ecto.setup

# Start the development server
mix phx.server
```

### 3. Test User Login
- **Email**: `admin@example.com`
- **Password**: `password123456`
- **URL**: `http://localhost:4000`

## 🌐 Deploy to Fly.io

### 1. Install Fly CLI
```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Add to PATH (Linux/Mac)
export PATH="$HOME/.fly/bin:$PATH"
```

### 2. Authenticate
```bash
# Login to Fly.io
fly auth login
```

### 3. Deploy
```bash
# Launch the app (uses existing fly.toml)
fly launch

# Set your OpenAI API key (required for caption analysis)
fly secrets set OPENAI_API_KEY=your_openai_api_key_here

# Deploy the application
fly deploy
```

### 4. Database Setup
The app will automatically:
- Run database migrations on first deploy
- Seed the test user (`admin@example.com` / `password123456`)

### 5. Access Your App
```bash
# Open your deployed app
fly open
```

## 🔧 Environment Variables

### Required
- `OPENAI_API_KEY` - Your OpenAI API key for GPT-4.1 integration

### Automatic (set by Fly.io)
- `DATABASE_URL` - SQLite database connection
- `SECRET_KEY_BASE` - Phoenix secret key
- `PHX_HOST` - Your app's hostname

## 🏗️ Architecture

### Tech Stack
- **Phoenix LiveView** - Real-time web framework
- **SQLite** - Database (with automatic backups on Fly.io)
- **OpenAI GPT-4.1** - AI-powered caption analysis
- **TailwindCSS + DaisyUI** - Styling framework
- **Fly.io** - Deployment platform

### Key Features
- 🔐 **Full user authentication** (registration, login, password reset)
- 🖼️ **Caption analysis** with AI feedback
- 🎨 **Beautiful yearbook-themed design**
- 📱 **Mobile responsive**
- ⚡ **Real-time updates**

## 🔍 Application Structure

```
lib/
├── proofie/
│   ├── accounts/          # User authentication
│   ├── openai_client.ex   # GPT-4.1 integration
│   └── repo.ex           # Database interface
└── proofie_web/
    ├── live/
    │   ├── dashboard_live.ex     # Main dashboard
    │   └── ai_checker_live.ex    # Caption analysis tool
    ├── components/
    │   └── layouts.ex            # App layouts
    └── router.ex                 # URL routing
```

## 🐛 Troubleshooting

### Common Issues
1. **OpenAI API errors**: Make sure `OPENAI_API_KEY` is set
2. **Database issues**: Run `fly ssh console` then `/app/bin/proofie eval "Proofie.Release.migrate"`
3. **Build failures**: Check Dockerfile and ensure all dependencies are correct

### Support Commands
```bash
# View app logs
fly logs

# SSH into running app
fly ssh console

# Scale app
fly scale count 1

# Check app status
fly status
```

## 🎯 Post-Deployment

1. **Test the application** at your Fly.io URL
2. **Login with test user** to verify functionality
3. **Test caption analysis** to ensure OpenAI integration works
4. **Monitor logs** for any issues: `fly logs`

Your Proofie app is now live! 🎉

