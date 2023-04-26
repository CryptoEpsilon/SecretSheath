# frozen_string_literal: true

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
      SecretSheath::CreateFolderForOwner.call(
        owner_id: account.id, folder_data: fold_data
      )
    end
  end
end

def create_keys
  key_info_each = KEY_INFO.each
  folders_cycle = SecretSheath::Folder.all.cycle
  loop do
    k_info = key_info_each.next
    folder = folders_cycle.next
    SecretSheath::CreateKeyForFolder.call(
      folder_id: folder.id, key_data: k_info
    )
  end
end

def add_sharers
  shar_info = SHARER_INFO
  shar_info.each do |shar|
    key = SecretSheath::Key.first(name: shar['name'])
    shar['sharer_email'].each do |email|
      SecretSheath::AddSharerToKey.call(
        email:, key_id: key.id
      )
    end
  end
end
