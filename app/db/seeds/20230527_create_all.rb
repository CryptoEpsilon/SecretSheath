# frozen_string_literal: true

require './app/controllers/helpers'
include SecretSheath::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, folders, keys'
    create_accounts
    create_owned_folders
    create_keys
    add_sharers
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_folders.yml")
FOLDER_INFO = YAML.load_file("#{DIR}/folders_seed.yml")
KEY_INFO = YAML.load_file("#{DIR}/keys_seed.yml")
SHARER_INFO = YAML.load_file("#{DIR}/keys_sharers.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    SecretSheath::Account.create(account_info)
  end
end

def create_owned_folders
  OWNER_INFO.each do |owner|
    account = SecretSheath::Account.first(username: owner['username'])
    owner['folder_name'].each do |folder_name|
      fold_data = FOLDER_INFO.find { |folder| folder['name'] == folder_name }
      account.add_owned_folder(fold_data)
    end
  end
end

def create_keys
  ACCOUNTS_INFO.each do |account_info|
    account = SecretSheath::Account.first(username: account_info['username'])
    masterkey = account.assemble_masterkey(account_info['password'])
    auth_token = AuthToken.create(account.to_h.merge(masterkey:))
    auth = scoped_auth(auth_token)

    key_info_each = KEY_INFO.each
    folders_cycle = account.owned_folders.cycle
    loop do
      k_info = key_info_each.next
      folder = folders_cycle.next

      SecretSheath::CreateKey.call(
        auth:, folder:, key_data: k_info
      )
    end
  end
end

# def add_sharers
#   shar_info = SHARER_INFO
#   shar_info.each do |shar|
#     key = SecretSheath::Key.first(name: shar['name'])

#     auth_token = AuthToken.create(key.owner)
#     auth = scoped_auth(auth_token)

#     shar['sharer_email'].each do |email|
#       SecretSheath::AddSharerToKey.call(
#         auth:, key:, sharer_email: email
#       )
#     end
#   end
# end
