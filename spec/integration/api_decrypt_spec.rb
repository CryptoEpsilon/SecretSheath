# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Decryption route' do
  include Rack::Test::Methods

  before do
    wipe_database
    header 'CONTENT_TYPE', 'application/json'

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = SecretSheath::Account.create(@account_data)
    @wrong_account = SecretSheath::Account.create(@wrong_account_data)

    @plaintext_data = { 'plaintext' => 'encryption test', 'expire_in' => 1 }
    @folder = @account.add_owned_folder(DATA[:folders][0])
    ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
    @key = @folder.add_key(DATA[:keys][0])

    @auth = authorization(@account_data)
    @encrypted_data = SecretSheath::EncryptData.call(
      auth: @auth,
      key: @key,
      plaintext_data: @plaintext_data['plaintext'],
      expire_in: @plaintext_data['expire_in']
    )
  end

  it 'HAPPY: should decrypt data with valid key' do
    header 'AUTHORIZATION', auth_header(@account_data)
    post "/api/v1/decrypt/#{@folder.name}/#{@key.alias}", @encrypted_data[:attributes].to_json

    result = JSON.parse(last_response.body)['data']['attributes']
    _(last_response.status).must_equal 200
    _(result['plaintext']).wont_be_nil
    _(result['plaintext']).must_equal @plaintext_data['plaintext']
  end

  it 'SAD: should not decrypt expired data' do
    sleep 2
    header 'AUTHORIZATION', auth_header(@account_data)
    post "/api/v1/decrypt/#{@folder.name}/#{@key.alias}", @encrypted_data[:attributes].to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 400
    _(result['message']).must_equal 'Invalid secret'
  end

  it 'SAD: should not decrypt data with invalid key' do
    header 'AUTHORIZATION', auth_header(@wrong_account_data)
    post '/api/v1/decrypt/invalid_folder/invalid_key', @plaintext_data.to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 404
    _(result['message']).must_equal 'We could not find that Key'
  end

  it 'BAD: should not decrypt without authorization' do
    post '/api/v1/decrypt/invalid_folder/invalid_key', @plaintext_data.to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 403
    _(result['message']).must_equal 'Unauthorized Request'
  end
end
