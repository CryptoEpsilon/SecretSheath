# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Utilities
gem 'time'

# Web API
gem 'json'
gem 'puma', '~>5.6'
gem 'roda', '~>3.54'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb'
gem 'sequel', '~>5.55'

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.4'
end

group :production do
  gem 'pg'
end

# Performance
gem 'rubocop-performance'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Debugging
gem 'pry'
gem 'rerun'

# Quality
gem 'rubocop'

# logger
gem 'logger'
