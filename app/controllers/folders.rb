# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('folders') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @folder_route = "#{@api_root}/folders"

      routing.on String do |folder_name|
        # GET api/v1/folders/[name]
        routing.get do
          @req_folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          folder = GetFolderQuery.call(account: @auth_account, folder: @req_folder)
          { data: folder }.to_json
        rescue GetFolderQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue GetFolderQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        end

        # GET api/v1/folders/[name]/keys
        routing.get 'keys' do
          keys = Folder.first(name: folder_name).keys
          keys ? keys.to_json : raise('No Keys')
        end
      rescue StandardError => e
        puts "ERROR: #{e.inspect}"
        routing.halt 500, { message: e.message }.to_json
      end

      # GET api/v1/folders
      routing.get do
        account = Account.first(username: @auth_account[:username])
        folders = account.owned_folders
        JSON.pretty_generate(data: folders)
      rescue StandardError
        routing.halt 404, { message: 'Could not find any folders' }.to_json
      end

      # POST api/v1/folders
      routing.post do
        new_req = JSON.parse(routing.body.read)
        new_folder = @auth_account.add_owned_folder(new_req)
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
    # rubocop:enable Metrics/BlockLength
  end
end
