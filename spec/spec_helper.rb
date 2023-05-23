# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'
require_relative '../app/lib/secure_db'

def wipe_database
  SecretSheath::Folder.map(&:destroy)
  SecretSheath::Key.map(&:destroy)
  SecretSheath::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = SecretSheath::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  keys: YAML.safe_load(File.read('app/db/seeds/keys_seed.yml')),
  folders: YAML.safe_load(File.read('app/db/seeds/folders_seed.yml')),
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml'))
}.freeze
