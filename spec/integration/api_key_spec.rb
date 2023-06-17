# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Key Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = SecretSheath::Account.create(@account_data)
    @folder = @account.add_owned_folder(DATA[:folders][0])

    @wrong_account = SecretSheath::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Get key info' do
    it 'HAPPY: should return key\'s information' do
      ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
      @folder = @account.owned_folders.first
      key = @folder.add_key(DATA[:keys][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/keys/#{@folder.name}/#{key.alias}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['attributes']
      _(result['name']).must_equal key.name
      _(result['description']).must_equal key.description
    end

    it 'SAD AUTHORIZATION: should not retrieve key\'s information without authorization' do
      ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
      @folder = @account.owned_folders.first
      key = @folder.add_key(DATA[:keys][0])

      get "/api/v1/keys/#{@folder.name}/#{key.alias}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if key dies not exists' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/keys/#{@folder.name}/unknown"

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
      key = @folder.add_key(DATA[:keys][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/keys/#{@folder.name}/#{key.alias}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 404
      _(result['message']).must_equal 'We could not find Key'
    end
  end

  describe 'Create key' do
    before do
      @key_data = DATA[:keys][1]
    end

    it 'HAPPY: should create a new key' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "/api/v1/keys/#{@folder.name}", @key_data.to_json
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)
      _(result['name']).must_equal @key_data['name']
      _(result['description']).must_equal @key_data['description']
    end

    it 'BAD AUTHORIZATION: should not create a new key with wrong authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "/api/v1/keys/#{@folder.name}", @key_data.to_json

      result = JSON.parse last_response.body
      _(last_response.status).must_equal 404
      _(result['message']).must_equal 'Could not save key'
    end

    it 'SAD: should not create a new key with same name in same folder' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "/api/v1/keys/#{@folder.name}", @key_data.to_json
      post "/api/v1/keys/#{@folder.name}", @key_data.to_json

      result = JSON.parse(last_response.body)
      _(last_response.status).must_equal 409
      _(result['message']).must_equal 'Key already exists in this folder'
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/keys/#{@folder.name}", @key_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @key_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/keys/#{@folder.name}", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end

  describe 'Delete key' do
    before do
      @key_data = DATA[:keys][1]
      ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
      @key = @folder.add_key(@key_data)
    end

    it 'HAPPY: should delete a key' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "/api/v1/keys/#{@folder.name}/#{@key.alias}"

      deleted_key = @folder.keys.find { |key| key.alias == @key.alias }
      result = JSON.parse(last_response.body)
      _(last_response.status).must_equal 200
      _(result['message']).must_equal "Key '#{@key.name}' deleted"
      _(deleted_key).must_be_nil
    end

    it 'BAD: should not delete a key with wrong authorization' do
      delete "/api/v1/keys/#{@folder.name}/#{@key.alias}"

      _(last_response.status).must_equal 403
      _(last_response.body['data']).must_be_nil
    end

    it 'SAD: should not delete a key that does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "/api/v1/keys/#{@folder.name}/unknown"

      _(last_response.status).must_equal 404
    end
  end
end
