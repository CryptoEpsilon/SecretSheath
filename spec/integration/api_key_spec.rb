# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Key Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:folders].each do |folder|
      SecretSheath::Folder.create(folder).save
    end
  end

  describe 'Happy test' do
    it 'HAPPY: should create a new key' do
      post '/api/v1/keys/default', DATA[:keys][0].to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)
      _(result['name']).must_equal DATA[:keys][0]['name']
      _(result['description']).must_equal DATA[:keys][0]['description']
    end

    it 'HAPPY: should list all keys in a folder' do
      directory = SecretSheath::Folder.first(name: 'default')
      DATA[:keys].each do |key|
        directory.add_key(key)
      end

      get '/api/v1/keys/default'
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['keys'].count).must_equal 2
    end

    DATA[:folders][1..2].zip(DATA[:keys]).each do |folder, key|
      it "HAPPY: should retrieve key's information in folder: \"#{folder['name']}\"" do
        f = SecretSheath::Folder.first(name: folder['name'])
        new_key = f.add_key(key)

        get "/api/v1/keys/#{folder['name']}/#{new_key.id}"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result['data']['attributes']['name']).must_equal key['name']
      end
    end
  end

  describe 'Sad test' do
    it 'SAD: should not create a new key' do
      post '/api/v1/keys/should_not_exist', DATA[:keys][0].to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 404
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Folder not found'
    end

    it 'SAD: should not list all keys in a folder' do
      get '/api/v1/keys/should_not_exist'
      _(last_response.status).must_equal 404
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Folder not found'
    end

    it 'SAD: should not retrieve key\'s information' do
      get '/api/v1/keys/default/should_not_exist'
      _(last_response.status).must_equal 404
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Key not found'
    end
  end

  describe 'Security test' do
    it 'SECURITY: should not create a new key with massive assignment' do
      post '/api/v1/keys/default', { name: 'test invalid', id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 400
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Invalid key request'
    end
  end
end
