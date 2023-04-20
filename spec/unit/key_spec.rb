# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test key Handling' do
  before do
    wipe_database

    SecretSheath::Folder.create(name: 'default', description: 'default folder').save
  end

  it 'HAPPY: should retrieve correct data from database' do
    data = DATA[:keys][0]
    folder = SecretSheath::Folder.first(name: 'default')
    data[:content] = SecureDB.generate_key
    key = folder.add_key(data)
    _(key.name).must_equal data['name']
    _(key.description).must_equal data['description']
    _(key.content).must_equal data[:content]
    _(key.alias).wont_equal data['alias']
    _(key.alias).must_equal key.id[0..7]
  end

  it 'SECURITY: should not use deterministic integer' do
    data = DATA[:keys][0]
    folder = SecretSheath::Folder.first(name: 'default')
    key = folder.add_key(data)

    _(key.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should not store key in plain text' do
    data = DATA[:keys][0]
    folder = SecretSheath::Folder.first(name: 'default')
    data[:content] = SecureDB.generate_key
    folder.add_key(data)
    stored_key = app.DB[:keys].first

    _(stored_key[:content_encrypted]).wont_equal data['content']
    _(stored_key[:description_encrypted]).wont_equal data['description']
  end
end
