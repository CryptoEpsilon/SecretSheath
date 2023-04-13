# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Folder Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    SecretSheath::Folder.create(name: 'default', description: 'default folder').save
  end

  describe 'Happy test' do
    it 'HAPPY: should have default folder' do
      get '/api/v1/folders'
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['folders'][0]['data']['attributes']['name']).must_equal 'default'
    end
    it 'HAPPY: should return list of folders' do
      SecretSheath::Folder.create(DATA[:folders][0]).save
      SecretSheath::Folder.create(DATA[:folders][1]).save
      get '/api/v1/folders'
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['folders'].count).must_equal 3
    end
    it 'HAPPY: should create a new folder' do
      post '/api/v1/folders', DATA[:folders][0].to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)
      _(result['name']).must_equal DATA[:folders][0]['name']
    end
    it 'HAPPY: should retrieve folder\'s information' do
      SecretSheath::Folder.create(DATA[:folders][0]).save
      get "/api/v1/folders/#{DATA[:folders][0]['name']}"
      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['data']['attributes']['name']).must_equal DATA[:folders][0]['name']
      _(result['data']['attributes']['description']).must_equal DATA[:folders][0]['description']
    end
  end
  describe 'Sad test' do
    it 'SAD: should not retrieve folder\'s information' do
      get '/api/v1/folders/should_not_exist'
      _(last_response.status).must_equal 404
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Folder not found'
    end
  end
end
