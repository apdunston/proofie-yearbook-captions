# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :proofie, :scopes,
  user: [
    default: true,
    module: Proofie.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: Proofie.AccountsFixtures,
    test_login_helper: :register_and_log_in_user
  ]

config :proofie,
  ecto_repos: [Proofie.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :proofie, ProofieWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ProofieWeb.ErrorHTML, json: ProofieWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Proofie.PubSub,
  live_view: [signing_salt: "1vZChCGc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  proofie: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  proofie: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Enveloop email service\
#config :proofie, :enveloop,
#  api_key: System.get_env("ENVELOOP_LIVE_API_KEY"),
#  template: System.get_env("ENVELOOP_TEMPLATE_ID")

config :proofie, Proofie.Mailer,
  adapter: Proofie.EnveloopAdapter,
  api_key: System.get_env("ENVELOOP_SANDBOX_API_KEY"),
  template: System.get_env("ENVELOOP_TEMPLATE_ID")


config :proofie, :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  model: "gpt-4"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
