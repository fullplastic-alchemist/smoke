import Config

if config_env() == :prod do
  config :smoke, port: System.get_env("PORT") || raise("environment variable PORT is missing")
end
