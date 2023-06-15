# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module SecretSheath
  # Holds a full secret keys
  class Key < Sequel::Model
    many_to_one :folder

    one_to_many :children, class: :'SecretSheath::ChildKey', key: :parent_id

    plugin :association_dependencies,
           children: :destroy

    plugin :timestamps
    plugin :uuid, field: :alias
    plugin :whitelist_security
    set_allowed_columns :name, :description, :content

    def before_save
      raw_key = ProtectedKey.generate_key if content.nil?
      self.content = ProtectedKey.encrypt(raw_key)
      self.short_alias = self.alias.to_s[0..7]
      super
    end

    def type
      'key'
    end

    def accessors(account = nil)
      account ? children.map(&:accessor).flatten.find { |a| a == account } : children.map(&:accessor).flatten
    end

    def owner
      folder.owner
    end

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_encrypted)
    end

    def description=(plaintext)
      self.description_encrypted = SecureDB.encrypt(plaintext)
    end

    def content
      protected_raw64 = SecureDB.decrypt(content_encrypted)
      ProtectedKey.decrypt(protected_raw64)
    end

    def content=(plaintext)
      self.content_encrypted = SecureDB.encrypt(plaintext)
    end

    def delete_all_children
      children.map(&:destroy)
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'key',
        attributes: {
          id:,
          name:,
          description:,
          alias:,
          short_alias:,
          created_at:
        },
        include: {
          folder:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          children: children.map(&:full_details)
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
