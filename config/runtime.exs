import Config

config :smoke, port: System.get_env("PORT") || raise("environment variable PORT is missing")
