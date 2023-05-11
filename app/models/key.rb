# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module SecretSheath
  # Holds a full secret document
  class Key < Sequel::Model
    many_to_one :folder

    many_to_many :shared_keys,
                 class: :'SecretSheath::Account',
                 join_table: :accounts_keys,
                 left_key: :key_id, right_key: :sharer_id

    plugin :association_dependencies,
           shared_keys: :nullify

    plugin :timestamps
    plugin :uuid, field: :alias
    plugin :whitelist_security
    set_allowed_columns :name, :description, :content

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_encrypted)
    end

    def description=(plaintext)
      self.description_encrypted = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_encrypted)
    end

    def content=(plaintext)
      self.content_encrypted = SecureDB.encrypt(plaintext)
    end

    def before_save
      self.content = SecureDB.generate_key if content.nil?
      self.short_alias = self.alias.to_s[0..7]
      super
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
              alias:,
              short_alias:,
              created_at:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
