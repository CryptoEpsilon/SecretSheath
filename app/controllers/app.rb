# frozen_string_literal: true

require 'roda'
require 'json'
require_relative '../../require_app'

require_app('models')

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'SecretSheath API up at /api/v1' }.to_json
      end

      routing.on 'api/v1' do
        @api_route = 'api/v1'

        # POST api/v1/login
        # routing.on 'login' do
        #   routing.post do
        #     credentials = JSON.parse(routing.body.read)
        #     account = Account.first(username: credentials['username'])
        #     raise('Username or Password is invalid') unless account || account.password?(credentials['password'])

        #     { message: 'Login successful', data: account }.to_json
        #   rescue StandardError
        #     routing.halt 401, { message: error.message }.to_json
        #   end
        # end

        routing.on 'accounts' do
          @account_route = "#{@api_route}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            # new_account.add_owned_folder(name: 'default', description: 'Default folder')
            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        routing.on 'keys' do
          @key_route = "#{@api_route}/keys"
          routing.on String do |folder_name|
            q = Folder.first(name: folder_name)
            folder_id = q ? q.id : raise('Folder not found')

            # GET api/v1/keys/[folder_name]/[key_id]
            routing.get String do |key_id|
              response.status = 200
              key_info = Key.first(id: key_id, folder_id:)
              key_info ? key_info.to_json : raise('Key not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # GET api/v1/keys/[folder_name]
            routing.get do
              response.status = 200
              { keys: Key.where(folder_id:).all }.to_json
            end

            # POST api/v1/keys/[folder_name]
            routing.post do
              new_req = JSON.parse(routing.body.read)
              new_key = CreateKeyForFolder.call(folder_id:, key_data: new_req)
              # folder = Folder.first(name: folder_name)
              # new_key = folder.add_key(new_req)
              raise 'Could not save key' unless new_key

              response.status = 201
              response['Location'] = "#{@key_route}/#{folder_name}/#{new_key.id}"
              { message: 'Key saved',
                id: new_key.id,
                name: new_key.name,
                description: new_key.description,
                alias: new_key.alias,
                created_at: new_key.created_at }.to_json
            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "[MASS-ASSIGNMENT]: Attempt to set disallowed column: #{new_req}"
              routing.halt 400, { message: 'Invalid key request' }.to_json
            rescue StandardError => e
              routing.halt 500, { message: e.message }.to_json
            end
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        routing.on 'folders' do
          @folder_route = "#{@api_route}/folders"

          # GET api/v1/folders/[name]
          routing.get String do |folder_name|
            folder = Folder.first(name: folder_name)
            folder ? folder.to_json : raise('Folder not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/folders
          routing.get do
            all_folders = { folders: Folder.all }
            JSON.pretty_generate(all_folders)
          end

          # POST api/v1/folders
          routing.post do
            new_req = JSON.parse(routing.body.read)
            new_folder = Folder.new(new_req)
            raise 'Could create folder' unless new_folder.save

            response.status = 201
            response['Location'] = "#{@folder_route}/#{new_folder.id}"
            { message: 'Folder create',
              id: new_folder.id,
              name: new_folder.name,
              created_at: new_folder.created_at }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "[MASS-ASSIGNMENT]: Attempt to set disallowed column: #{new_req}"
            routing.halt 400, { message: 'Invalid folder request' }.to_json
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
