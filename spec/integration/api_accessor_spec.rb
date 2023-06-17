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
    @accessor_data = DATA[:accounts][1]

    @owner = SecretSheath::Account.all[0]
    @accessor = SecretSheath::Account.all[1]
    @folder = @owner.add_owned_folder(folder_data)
    ProtectedKey.setup(@owner.assemble_masterkey(@owner_data['password']))
    @key = @folder.add_key(key_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Get accessor of the key' do
    before do
      auth = authorization(@owner_data)
      SecretSheath::AddAccessor.call(
        auth:,
        accessor_email: @accessor.email,
        key: @key
      )
    end

    it 'HAPPY: should return accessor of the key' do
      header 'AUTHORIZATION', auth_header(@owner_data)
      get "/api/v1/keys/#{@folder.name}/#{@key.alias}/accessors"

      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)['data'][0]
      _(result['attributes']['username']).must_equal @accessor.username
      _(result['attributes']['email']).must_equal @accessor.email
    end

    it 'HAPPY: should appear in the accessor\'s shared folder' do
      header 'AUTHORIZATION', auth_header(@accessor_data)
      get '/api/v1/folders/Shared'
      shared_key = @owner.children_keys.first

      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)['data']['relationships']
      _(result['keys'][0]['attributes']['name']).must_equal shared_key.name
      _(result['keys'][0]['attributes']['alias']).must_equal shared_key.alias
    end
  end

  describe 'Add accessor to key' do
    it 'HAPPY: should add accessor to key' do
      header 'AUTHORIZATION', auth_header(@owner_data)
      put "/api/v1/keys/#{@folder.name}/#{@key.alias}/accessors",
          { email: @accessor.email }.to_json

      shared_key = @accessor.shared_keys.first
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal shared_key.id
      _(result['attributes']['name']).must_equal shared_key.name
      _(result['attributes']['alias']).must_equal shared_key.alias
    end

    it 'SAD: should not add the same accessor to the key' do
      auth = authorization(@owner_data)
      SecretSheath::AddAccessor.call(
        auth:,
        accessor_email: @accessor.email,
        key: @key
      )

      header 'AUTHORIZATION', auth_header(@owner_data)
      put "/api/v1/keys/#{@folder.name}/#{@key.alias}/accessors",
          { email: @accessor.email }.to_json

      result = JSON.parse(last_response.body)
      _(last_response.status).must_equal 403
      _(result['message']).must_equal 'You are not allowed to invite that person as accessor'
    end
  end

  describe 'Decrypt with shared key' do
    before do
      auth = authorization(@owner_data)
      @shared_key = SecretSheath::AddAccessor.call(
        auth:,
        accessor_email: @accessor.email,
        key: @key
      )
      @plaintext_data = { plaintext_data: 'this is test', expire_in: 3600 }
      @encrypted_data = SecretSheath::EncryptData.call(
        auth:,
        key: @key,
        plaintext_data: @plaintext_data[:plaintext_data],
        expire_in: @plaintext_data[:expire_in]
      )
    end

    it 'HAPPY: should decrypt with shared key' do
      shared_key = @accessor.access.first
      header 'AUTHORIZATION', auth_header(@accessor_data)
      post "/api/v1/decrypt/Shared/#{shared_key.alias}", @encrypted_data[:attributes].to_json

      result = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 200
      _(result['attributes']['plaintext']).must_equal @plaintext_data[:plaintext_data]
    end
  end

  describe 'Delete accessor from key' do
    before do
      auth = authorization(@owner_data)
      @shared_key = SecretSheath::AddAccessor.call(
        auth:,
        accessor_email: @accessor.email,
        key: @key
      )
    end

    it 'HAPPY: should delete accessor from key' do
      header 'AUTHORIZATION', auth_header(@owner_data)
      delete "/api/v1/keys/#{@folder.name}/#{@key.alias}/accessors",
             { email: @accessor.email }.to_json

      _(last_response.status).must_equal 200
      _(@owner.children_keys).must_be_empty
    end
  end
end
