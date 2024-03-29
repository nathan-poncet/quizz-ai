import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :quizz, Quizz.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quizz_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quizz, QuizzWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "oMAWJGf1eoaZnYu4bkKte34nr+W23rjf+hPCFNmeYUeVNOPoDxf9d1t6vvS8hCGz",
  server: false

# In test we don't send emails.
config :quizz, Quizz.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :openai,
  api_key: "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",
  organization_key: "org-SjrVaTrzC6lRADUgoi3GVT0t",
  http_options: [recv_timeout: 30_000]
