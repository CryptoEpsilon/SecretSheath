# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Folder Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = SecretSheath::Account.create(@account_data)
    @wrong_account = SecretSheath::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Get folder info' do
    describe 'Get list of folders' do
      before do
        @account.add_owned_folder(DATA[:folders][0])
        @account.add_owned_folder(DATA[:folders][1])
      end

      it 'HAPPY: should have Shared folder' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get '/api/v1/folders'
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result['data'][2]['attributes']['name']).must_equal 'Shared'
      end

      it 'HAPPY: should return list of folders for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get '/api/v1/folders'
        _(last_response.status).must_equal 200

        result = JSON.parse(last_response.body)
        _(result['data'].count).must_equal 3
      end

      it 'HAPPY: should list all keys in a folder' do
        ProtectedKey.setup(@account.assemble_masterkey(@account_data['password']))
        folder = @account.owned_folders.first
        folder.add_key(DATA[:keys][0])
        folder.add_key(DATA[:keys][1])

        header 'AUTHORIZATION', auth_header(@account_data)
        get "/api/v1/folders/#{folder.name}/keys"
        _(last_response.status).must_equal 200
        result = JSON.parse(last_response.body)
        _(result['data'].count).must_equal 2
      end

      it 'HAPPY: should return folder\'s information' do
        folder = @account.add_owned_folder(DATA[:folders][0])

        header 'AUTHORIZATION', auth_header(@account_data)
        get "/api/v1/folders/#{folder.name}"
        _(last_response.status).must_equal 200

        result = JSON.parse(last_response.body)['data']['attributes']
        _(result['name']).must_equal folder.name
        _(result['description']).must_equal folder.description
      end

      it 'SAD: should not retrieve folder\'s information' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get '/api/v1/folders/should_not_exist'
        _(last_response.status).must_equal 404
        result = JSON.parse(last_response.body)
        _(result['message']).must_equal 'We could not find that Folder'
      end

      it 'BAD: should not retrieve folder with wrong authorization' do
        folder = @account.add_owned_folder(DATA[:folders][0])

        header 'AUTHORIZATION', auth_header(@wrong_account_data)
        get "/api/v1/folders/#{folder.name}"
        _(last_response.status).must_equal 404
        result = JSON.parse(last_response.body)
        _(result['message']).must_equal 'We could not find that Folder'
      end

      it 'BAD SQL injection: should prevent SQL injection' do
        @account.add_owned_folder(DATA[:folders][0])
        @account.add_owned_folder(DATA[:folders][1])

        header 'AUTHORIZATION', auth_header(@account_data)
        get '/api/v1/folders/1%3B%20DROP%20TABLE%20folders'

        _(last_response.status).must_equal 404
        _(last_response.body['data']).must_be_nil
      end
    end
  end

  describe 'Create new folder' do
    before do
      @folder_data = DATA[:folders][0]
      @new_folder_data = DATA[:folders][2]
    end

    it 'HAPPY: should create a new folder' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post '/api/v1/folders', @new_folder_data.to_json

      _(last_response.status).must_equal 201
      result = JSON.parse(last_response.body)
      folder_info = result['data']['attributes']
      folder = SecretSheath::Folder.first(name: @new_folder_data['name'])

      _(result['message']).must_equal 'Folder created'
      _(folder_info['id']).must_equal folder.id
      _(folder_info['name']).must_equal folder.name
      _(folder_info['description']).must_equal folder.description
    end

    it 'SAD: should not create folder with same name' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post '/api/v1/folders', @folder_data.to_json
      post '/api/v1/folders', @folder_data.to_json

      _(last_response.status).must_equal 409
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'Folder already exists'
    end

    it 'SAD: should not create new folder without authorization' do
      post '/api/v1/folders', @folder_data.to_json

      res = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(res).must_be_nil
    end

    it 'SECURITY: should not create folder with mass assignment' do
      bad_data = @folder_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/folders', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end

  describe 'Delete folder' do
    before do
      @folder_data = DATA[:folders][0]
      @folder = @account.add_owned_folder(@folder_data)
    end

    it 'HAPPY: should delete folder' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "/api/v1/folders/#{@folder_data['name']}"

      deleted_folder = @account.owned_folders.find { |f| f.name == @folder_data['name'] }

      _(last_response.status).must_equal 200
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal "Folder '#{@folder.name}' deleted successfully"
      _(deleted_folder).must_be_nil
    end

    it 'BAD: should not delete folder without authorization' do
      delete "/api/v1/folders/#{@folder_data['name']}"

      _(last_response.status).must_equal 403
      _(last_response.body['data']).must_be_nil
    end

    it 'SAD: should not delete folder that does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete '/api/v1/folders/should_not_exist'

      _(last_response.status).must_equal 404
      result = JSON.parse(last_response.body)
      _(result['message']).must_equal 'We could not find that Folder'
    end
  end
end
