# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddAccessor service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      SecretSheath::Account.create(account_data)
    end

    folder_data = DATA[:folders].first
    key_data = DATA[:keys].first

    @owner_data = DATA[:accounts][0]
    @owner = SecretSheath::Account.all[0]
    @accessor = SecretSheath::Account.all[1]
    @folder = @owner.add_owned_folder(folder_data)
    ProtectedKey.setup(@owner.assemble_masterkey(@owner_data['password']))
    @key = @folder.add_key(key_data)
  end

  it 'HAPPY: should add a accessor to a key' do
    auth = authorization(@owner_data)
    SecretSheath::AddAccessor.call(
      auth:,
      accessor_email: @accessor.email,
      key: @key
    )

    _(@accessor.shared_keys.count).must_equal 1
    _(@accessor.shared_keys.first).must_equal @owner.children_keys.first
  end

  it 'BAD: should not add owner as a accessor to a key' do
    auth = SecretSheath::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )

    _(proc {
      SecretSheath::AddAccessor.call(
        auth:,
        accessor_email: @owner.email,
        key: @key
      )
    }).must_raise SecretSheath::AddAccessor::ForbiddenError
  end
end
