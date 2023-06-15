# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    plugin :halt
    plugin :all_verbs
    plugin :multi_route
    plugin :request_headers

    include SecureRequestHelpers

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth = authorization(routing.headers)
        @auth_account = @auth[:account] if @auth
        @masterkey = @auth[:masterkey] if @auth
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      rescue AuthToken::ExpiredTokenError
        routing.halt 403, { message: 'Expired auth token' }.to_json
      end

      routing.root do
        { message: 'SecretSheath API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
