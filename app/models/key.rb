# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module SecretSheath
  # Holds a full secret document
  class Key < Sequel::Model
    many_to_one :folder
    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    set_allowed_columns :name, :description, :content

     # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end	


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
              content:,
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
