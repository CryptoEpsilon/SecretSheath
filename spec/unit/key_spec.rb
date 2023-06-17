# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test key Handling' do
  before do
    wipe_database

    account = SecretSheath::Account.create(username: 'test', password: 'passrand', email: 'test@mail.com')
    account.add_owned_folder(name: 'default')
    ProtectedKey.setup(account.assemble_masterkey('passrand'))
  end

  it 'HAPPY: should retrieve correct data from database' do
    data = DATA[:keys][0].clone
    folder_id = SecretSheath::Folder.first(name: 'default').id
    key = SecretSheath::CreateKeyForFolder.call(folder_id:, key_data: data)
    _(key.name).must_equal data['name']
    _(key.description).must_equal data['description']
    _(key.alias).wont_equal data['alias']
    _(key.short_alias).must_equal key.alias[0..7]
  end

  it 'SECURITY: should not use deterministic integer' do
    data = DATA[:keys][0]
    folder_id = SecretSheath::Folder.first(name: 'default').id
    key = SecretSheath::CreateKeyForFolder.call(folder_id:, key_data: data)

    _(key.alias.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should not store key in plain text' do
    data = DATA[:keys][0]
    folder_id = SecretSheath::Folder.first(name: 'default').id
    SecretSheath::CreateKeyForFolder.call(folder_id:, key_data: data)
    stored_key = app.DB[:keys].first

    _(stored_key[:content_encrypted]).wont_equal data['content']
    _(stored_key[:description_encrypted]).wont_equal data['description']
  end
end
