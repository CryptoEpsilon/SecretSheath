# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module SecretSheath
  # Holds a full secret document
  class Key < Sequel::Model
    many_to_one :folders
    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'key',
            attributes: {
              id:,
              name:,
              description:,
              key_alias:,
              created_at:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.create_key
      Base64.urlsafe_encode64(RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes))
    end

    def self.create_alais(input)
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(input))[0..9]
    end
  end
end
