# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Encryption route' do
  include Rack::Test::Methods

  before do
    wipe_database
    header 'CONTENT_TYPE', 'application/json'

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = SecretSheath::Account.create(@account_data)
    @wrong_account = SecretSheath::Account.create(@wrong_account_data)

    @plaintext_data = { 'plaintext' => 'encryption test', 'expire_in' => '3600'}
    @folder = @account.add_owned_folder(DATA[:folders][0])
    ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
    @key = @folder.add_key(DATA[:keys][0])
  end

  it 'HAPPY: should encrypt data with valid key' do
    header 'AUTHORIZATION', auth_header(@account_data)
    post "/api/v1/encrypt/#{@folder.name}/#{@key.alias}", @plaintext_data.to_json

    result = JSON.parse(last_response.body)['data']['attributes']
    _(last_response.status).must_equal 200
    _(result['ciphertext']).wont_be_nil
    _(result['ciphertext']).wont_equal @plaintext_data['plaintext']
  end

  it 'SAD: should not encrypt data with invalid key' do
    header 'AUTHORIZATION', auth_header(@wrong_account_data)
    post '/api/v1/encrypt/invalid_folder/invalid_key', @plaintext_data.to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 404
    _(result['message']).must_equal 'We could not find that Key'
  end

  it 'BAD: should not encrypt without authorization' do
    post '/api/v1/encrypt/invalid_folder/invalid_key', @plaintext_data.to_json

    result = JSON.parse(last_response.body)
    _(last_response.status).must_equal 403
    _(result['message']).must_equal 'Unauthorized Request'
  end
end
