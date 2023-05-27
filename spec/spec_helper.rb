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

def authenticate(account_data)
  SecretSheath::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: SecretSheath::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end


DATA = {
  keys: YAML.safe_load(File.read('app/db/seeds/keys_seed.yml')),
  folders: YAML.safe_load(File.read('app/db/seeds/folders_seed.yml')),
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml'))
}.freeze
