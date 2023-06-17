# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    route('encrypt') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @folder_route = "#{@api_root}/encrypt"

      # POST api/v1/encrypt/[folder_name]/[key_alias]
      routing.post String, String do |folder_name, key_alias|
        enc_req = JSON.parse(routing.body.read)
        folder = Account.first(username: @auth_account[:username])
                        .owned_folders_dataset.first(name: folder_name)
        raise EncryptData::NotFoundError unless folder

        key = folder.keys_dataset.first(alias: key_alias)
        encrypted_data = EncryptData.call(
          auth: @auth,
          key:,
          plaintext_data: enc_req['plaintext'],
          expire_in: enc_req['expire_in'].to_i
        )
        { data: encrypted_data }.to_json
      rescue EncryptData::NotFoundError => e
        routing.halt(404, { message: e.message }.to_json)
      rescue EncryptData::ForbiddenError => e
        routing.halt(403, { message: e.message }.to_json)
      rescue StandardError => e
        routing.halt(500, { message: e.message }.to_json)
      end
    end
  end
end
