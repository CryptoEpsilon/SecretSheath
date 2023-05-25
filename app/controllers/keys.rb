# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength

    route('keys') do |routing|
      @key_route = "#{@api_root}/keys"

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

        # POST api/v1/keys/[folder_name]
        routing.post do
          key_data = JSON.parse(routing.body.read)
          folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          new_key = CreateKey.call(
            account: @auth_account,
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
        rescue CreateKey::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue CreateKey::IllegalRequestError  => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
