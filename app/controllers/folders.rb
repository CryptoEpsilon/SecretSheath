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

      # GET api/v1/folders/Shared
      routing.is 'Shared' do
        routing.get do
          shared_folders = GetFolderQuery.call(auth: @auth, folder: SharedFolder.new(@auth_account))
          { data: shared_folders }.to_json
        rescue GetFolderQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue GetFolderQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        end
      end

      routing.on String do |folder_name|
        # GET api/v1/folders/[name]/keys
        routing.get 'keys' do
          folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          keys = folder.keys
          keys ? { data: keys }.to_json : raise('No Keys')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # GET api/v1/folders/[name]
        routing.get do
          @req_folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          folder = GetFolderQuery.call(auth: @auth, folder: @req_folder)
          { data: folder }.to_json
        rescue GetFolderQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue GetFolderQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        end

        # DELETE api/v1/folders/[name]
        routing.delete do
          @req_folder = @auth_account.owned_folders_dataset.first(name: folder_name)
          DeleteFolder.call(auth: @auth, folder: @req_folder)
          { message: "Folder '#{@req_folder.name}' deleted successfully" }.to_json
        rescue DeleteFolder::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue DeleteFolder::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        end
      rescue StandardError => e
        puts "ERROR: #{e.inspect}"
        routing.halt 500, { message: e.message }.to_json
      end

      # GET api/v1/folders
      routing.get do
        folders = FolderPolicy::AccountScope.new(@auth_account, @auth[:scope]).viewable

        { data: folders.append(SharedFolder.new(@auth_account).to_h) }.to_json
      rescue StandardError
        routing.halt 404, { message: 'Could not find any folders' }.to_json
      end

      # POST api/v1/folders
      routing.post do
        new_req = JSON.parse(routing.body.read)

        new_folder = CreateFolderForOwner.call(auth: @auth, folder_data: new_req)

        response.status = 201
        response['Location'] = "#{@folder_route}/#{new_folder.id}"
        { message: 'Folder created', data: new_folder.to_h }.to_json
      rescue CreateFolderForOwner::DuplicateFolderError => e
        routing.halt 409, { message: e.message }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "[MASS-ASSIGNMENT]: Attempt to set disallowed column: #{new_req}"
        routing.halt 400, { message: 'Invalid folder request' }.to_json
      rescue CreateFolderForOwner::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
