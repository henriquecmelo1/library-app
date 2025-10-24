source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 8.0.3"

# --- Núcleo da API ---
gem "pg"                 # Banco de dados PostgreSQL
gem "puma", ">= 5.0"     # Servidor web
gem "bcrypt", "~> 3.1.7" # has_secure_password 
gem "jwt"                # Autenticação JWT 
gem "rack-cors"          # Para permitir requisições de outros domínios
gem "pagy"               # Paginação 
gem "httparty"           # Consome a API da OpenLibrary
gem "dotenv-rails"       # .env

# Windows does not include zoneinfo files
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching
gem "bootsnap", require: false

# --- Deployment (Opcional, mantenha se for usar) ---
# gem "kamal", require: false
# gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails"
end

group :development do
  # Ferramentas de análise de código (boas práticas)
  gem "brakeman", require: false
  gem "rubocop", require: false
end

group :test do
  gem "simplecov", require: false
  gem 'shoulda-matchers', '~> 5.0'
end