# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/key'

module SecretSheath
  # Web controller for SecretSheath API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Key.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'SecretSheath API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'keys' do
            # GET api/v1/keys/[id]
            routing.get String do |id|
              response.status = 200
              Key.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Key not found' }.to_json
            end

            # GET api/v1/keys
            routing.get do
              response.status = 200
              output = { key_ids: Key.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/keys
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Key.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Key saved', id: new_doc.id, time_created: new_doc.time_created }.to_json
              else
                routing.halt 400, { message: 'Could not save key' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
