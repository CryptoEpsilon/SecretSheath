# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Folder Handling' do
  before do
    wipe_database

    SecretSheath::Folder.create(name: 'default', description: 'default folder').save
  end

  it 'HAPPY: should have default folder' do
    folder = SecretSheath::Folder.first
    _(folder.name).must_equal 'default'
  end

  it 'HAPPY: should retrieve correct data from database' do
    data = DATA[:folders][0]
    folder = SecretSheath::Folder.create(data).save
    _(folder.name).must_equal data['name']
    _(folder.description).must_equal data['description']
  end

  it 'SECURITY: should not store description in plain text' do
    data = DATA[:folders][0]
    SecretSheath::Folder.create(data).save
    stored_folder = app.DB[:folders].first
    _(stored_folder[:description_encrypted]).wont_equal data['description']
  end
end
