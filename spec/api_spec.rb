# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/key'

def app
  SecretSheath::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/test_keys.yaml')

describe 'Test SecretSheath API' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{SecretSheath::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should return 200 when accessing root' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'SAD tests' do
    it 'SAD: should return 404 when accessing non-existent key' do
      get '/api/v1/keys/1'
      _(last_response.status).must_equal 404
    end
  end

  describe 'HAPPY tests' do
    it 'HAPPY: should return 201 when posting valid key' do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      DATA.each do |key|
        post '/api/v1/keys', key.to_json, headers
        _(last_response.status).must_equal 201
      end
    end

    it 'HAPPY: should return 200 when listing all keys' do
      get '/api/v1/keys'
      _(last_response.status).must_equal 200
    end

    it 'HAPPY: should return 200 when accessing existing key' do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/keys', DATA[0].to_json, headers
      id = JSON.parse(last_response.body)['id']

      get "/api/v1/keys/#{id}"
      res = JSON.parse(last_response.body)
      _(last_response.status).must_equal 200
      _(res['id']).must_equal id
    end
  end
end
