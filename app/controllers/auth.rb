# frozen_string_literal: true

require 'roda'
require_relative './app'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    route('auth') do |routing|
      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = JSON.parse(request.body.read, symbolize_names: true)
          auth_account = AuthenticateAccount.call(credentials)
          {
            type: 'account',
            id: auth_account.id,
            username: auth_account.username,
            email: auth_account.email,
            masterkey_salt: auth_account.masterkey_salt
          }.to_json
        rescue UnauthorizedError => e
          puts [e.class, e.message].join ': '
          routing.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end
    end
  end
end
