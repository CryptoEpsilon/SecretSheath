# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddSharerToKey service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      SecretSheath::Account.create(account_data)
    end

    folder_data = DATA[:folders].first
    key_data = DATA[:keys].first

    @owner = SecretSheath::Account.all[0]
    @sharer = SecretSheath::Account.all[1]
    @folder = SecretSheath::CreateFolderForOwner.call(owner_id: @owner.id, folder_data:)
    @key = SecretSheath::CreateKeyForFolder.call(folder_id: @folder.id, key_data:)
  end

  it 'HAPPY: should add a sharer to a key' do
    SecretSheath::AddSharerToKey.call(
      email: @sharer.email,
      key_id: @key.id
    )

    _(@sharer.keys.count).must_equal 1
    _(@sharer.keys.first).must_equal @key
  end

  it 'SAD: should not add a sharer to a key' do
    _(proc {
      SecretSheath::AddSharerToKey.call(
        email: @owner.email,
        key_id: @key.id
      )
    }).must_raise SecretSheath::AddSharerToKey::OwnerNotSharerError
  end
end
