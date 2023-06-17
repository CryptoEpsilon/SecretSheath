# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Folder Handling' do
  include Rack::Test::Methods

  before do
    header 'CONTENT_TYPE', 'application/json'
    wipe_database
  end

  describe 'Account information' do
    it 'HAPPY: it should get account details' do
      data = DATA[:accounts][0]
      account = SecretSheath::Account.create(data)

      header 'AUTHORIZATION', auth_header(data)
      get "/api/v1/accounts/#{account.username}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)['data']['attributes']
      result = response['account']['attributes']
      _(result['id']).must_equal account.id
      _(result['username']).must_equal account.username
      _(result['email']).must_equal account.email
      _(result['salt']).must_be_nil
      _(result['password']).must_be_nil
      _(result['password_digest']).must_be_nil
    end
  end

  describe 'Account creation' do
    before do
      @account_data = DATA[:accounts][2]
    end
    it 'HAPPY: it should create a new account' do
      post '/api/v1/accounts', 
           SignedRequest.new(app.config).sign(@account_data).to_json
      _(last_response.status).must_equal 201

      result = JSON.parse(last_response.body)['data']['attributes']
      account = SecretSheath::Account.first

      _(result['id']).must_equal account.id
      _(result['username']).must_equal account.username
      _(result['email']).must_equal account.email
      _(result['masterkey_salt']).must_be_nil
      _(result['public_key']).must_be_nil
      _(result['private_key_salt']).must_be_nil
      _(account.password?(DATA[:accounts][2]['password'])).must_equal true
      _(account.password?('wrong password')).must_equal false
    end

    it 'BAD MASS_ASSIGNMENT: it should not create a new account' do
      bad_data = DATA[:accounts][0].clone
      bad_data['created_at'] = '1996-01-18'
      post '/api/v1/accounts',
           SignedRequest.new(app.config).sign(bad_data).to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil

      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Illegal Request'
    end

    it 'BAD SIGNED_REQUEST: should not accept unsigned requests' do
      post 'api/v1/accounts', @account_data.to_json
      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
