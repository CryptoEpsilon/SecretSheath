# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    route('decrypt') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @folder_route = "#{@api_root}/decrypt"

      # POST api/v1/decrypt/Shared/[key_alias]
      routing.post 'Shared', String do |key_alias|
        dec_req = JSON.parse(routing.body.read)
        key = @auth_account.access_dataset.first(alias: key_alias)
        decrypted_data = DecryptData.call(
          auth: @auth,
          key:,
          secret_data: dec_req['ciphertext']
        )
        { data: decrypted_data }.to_json
      end

      # POST api/v1/decrypt/[folder_name]/[key_alias]
      routing.post String, String do |folder_name, key_alias|
        dec_req = JSON.parse(routing.body.read)
        key = Account.first(username: @auth_account[:username])
                     .owned_folders_dataset.first(name: folder_name)
                     .keys_dataset.first(alias: key_alias)
        decrypted_data = DecryptData.call(
          auth: @auth,
          key:,
          secret_data: dec_req['ciphertext']
        )
        { data: decrypted_data }.to_json
      rescue DecryptData::ForbiddenError => e
        routing.halt(403, { message: e.message }.to_json)
      rescue SecretData::InvalidSecretError => e
        routing.halt 400, { message: e.message }.to_json
      rescue RbNaCl::CryptoError => e
        routing.halt 404, { message: e.message }.to_json
      end
    end
  end
end
