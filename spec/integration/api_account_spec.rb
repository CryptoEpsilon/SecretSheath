# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Folder Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Happy test' do
    it 'HAPPY: it should get account details' do
      data = DATA[:accounts][0]
      account = SecretSheath::Account.create(data)

      get "/api/v1/accounts/#{account.username}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)
      _(result['id']).must_equal account.id
      _(result['username']).must_equal account.username
      _(result['email']).must_equal account.email
      _(result['salt']).must_be_nil
      _(result['password']).must_be_nil
      _(result['password_digest']).must_be_nil
    end

    it 'HAPPY: it should create a new account' do
      post '/api/v1/accounts', DATA[:accounts][2].to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 201

      result = JSON.parse(last_response.body)
      account = SecretSheath::Account.first

      _(result['data']['id']).must_equal account.id
      _(result['data']['username']).must_equal account.username
      _(result['data']['email']).must_equal account.email
      _(account.password?(DATA[:accounts][2]['password'])).must_equal true
      _(account.password?('wrong password')).must_equal false
    end
  end

  describe 'Sad test' do
    it 'SAD: it should not get account details' do
      get '/api/v1/accounts/should_not_exist'
      _(last_response.status).must_equal 404

      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Account not found'
    end

    it 'SAD: it should not create a new account' do
      data = DATA[:accounts][0].clone
      data['created_at'] = '1996-01-18'
      post '/api/v1/accounts', data.to_json, 'CONTENT_TYPE' => 'application/json'

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil

      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Illegal Request'
    end
  end
end
