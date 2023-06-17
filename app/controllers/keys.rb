# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  # rubocop:disable Metrics/BlockLength
  class Api < Roda 
    route('keys') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @key_route = "#{@api_root}/keys"
      response.status = 200

      routing.on 'Shared' do
        routing.on String do |key_alias|
          # GET api/v1/keys/Shared/[key_alias]
          routing.get do
            key = @auth_account.access_dataset.first(alias: key_alias)
            key_info = GetKeyQuery.call(auth: @auth, key:)
            { data: key_info }.to_json
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end
      end

      routing.on String do |folder_name|
        routing.on String do |key_alias|
          routing.is 'accessors' do
            # GET api/v1/keys/[folder_name]/[key_alias]/accessors
            routing.get do
              folder = @auth_account.owned_folders_dataset
                                    .first(name: folder_name)
              raise GetAccessorQuery::KeyNotFound unless folder

              key = folder.keys_dataset
                          .first(alias: key_alias)
              accessor = GetAccessorQuery.call(
                auth: @auth,
                key:
              )
              { data: accessor }.to_json
            rescue GetAccessorQuery::KeyNotFound => e
              routing.halt 404, { message: e.message }.to_json
            end

            # PUT api/v1/keys/[folder_name]/[key_alias]/accessors
            routing.put do
              req_data = JSON.parse(routing.body.read)
              folder = @auth_account.owned_folders_dataset
                                    .first(name: folder_name)
              raise AddAccessor::KeyNotFound unless folder

              key = folder.keys_dataset
                          .first(alias: key_alias)

              accessor = AddAccessor.call(
                auth: @auth,
                accessor_email: req_data['email'],
                key:
              )
              response.status = 201
              { data: accessor }.to_json
            rescue AddAccessor::KeyNotFound => e
              routing.halt 404, { message: e.message }.to_json
            rescue AddAccessor::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              routing.halt 500, { message: 'Internal server error' }.to_json
            end

            # DELETE api/v1/keys/[folder_name]/[key_alias]/accessors
            routing.delete do
              req_data = JSON.parse(routing.body.read)
              folder = @auth_account.owned_folders_dataset
                                    .first(name: folder_name)
              raise DeleteAccessor::KeyNotFound unless folder

              key = folder.keys_dataset
                          .first(alias: key_alias)

              deleted_accessor = DeleteAccessor.call(
                auth: @auth,
                accessor_email: req_data['email'],
                key:
              )
              { data: deleted_accessor }.to_json
            rescue DeleteAccessor::KeyNotFound => e
              routing.halt 404, { message: e.message }.to_json
            rescue DeleteAccessor::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              routing.halt 500, { message: 'Internal server error' }.to_json
            end
          end

          # GET api/v1/keys/[folder_name]/[key_alias]
          routing.get do
            folder = @auth_account.owned_folders_dataset
                                  .first(name: folder_name)

            raise GetKeyQuery::NotFoundError unless folder

            key = folder.keys_dataset
                        .first(alias: key_alias)
            key_info = GetKeyQuery.call(auth: @auth, key:)
            { data: key_info }.to_json
          rescue GetKeyQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetKeyQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # DELETE api/v1/keys/[folder_name]/[key_alias]
          routing.delete do
            folder = @auth_account.owned_folders_dataset
                                  .first(name: folder_name)

            raise DeleteKey::NotFoundError unless folder

            key = folder.keys_dataset
                        .first(alias: key_alias)
            DeleteKey.call(auth: @auth, key:)
            { message: "Key '#{key.name}' deleted" }.to_json
          rescue DeleteKey::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue DeleteKey::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end

        # POST api/v1/keys/[folder_name]
        routing.post do
          key_data = JSON.parse(routing.body.read)
          folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          new_key = CreateKey.call(
            auth: @auth,
            folder:,
            key_data:
          )
          raise 'Could not save key' unless new_key

          response.status = 201
          response['Location'] = "#{@key_route}/#{folder_name}/#{new_key.id}"
          { message: 'Key saved',
            id: new_key.id,
            name: new_key.name,
            description: new_key.description,
            alias: new_key.alias,
            short_alias: new_key.short_alias,
            created_at: new_key.created_at }.to_json
        rescue CreateKey::DuplicateKeyError => e
          routing.halt 409, { message: e.message }.to_json
        rescue CreateKey::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue CreateKey::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue CreateKey::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
