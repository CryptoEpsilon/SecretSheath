# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('folders') do |routing|
      @folder_route = "#{@api_root}/folders"

      # GET api/v1/folders/[name]
      routing.get String do |folder_name|
        folder = Folder.first(name: folder_name)
        folder ? folder.to_json : raise('Folder not found')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      # GET api/v1/folders
      routing.get do
        account = Account.first(username: @auth_account['username'])
        folders = account.projects
        JSON.pretty_generate(data: folders)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any folders' }.to_json
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
    # rubocop:enable Metrics/BlockLength
  end
end
