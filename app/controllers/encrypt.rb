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
        @enc_req = JSON.parse(routing.body.read)
        key = Account.first(username: @auth_account[:username])
                     .owned_folders_dataset.first(name: folder_name)
                     .keys_dataset.first(alias: key_alias)
        encrypted_data = EncryptData.call(
          auth: @auth,
          key:,
          plaintext_data: @enc_req['plaintext']
        )
        { data: encrypted_data }.to_json
      end
    end
  end
end
