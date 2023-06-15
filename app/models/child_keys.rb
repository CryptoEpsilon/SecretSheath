# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'
require 'sequel'

module SecretSheath
  # Holds a full secret document
  class ChildKey < Sequel::Model
    many_to_one :parent, class: :'SecretSheath::Key'

    many_to_many :accessor,
                 class: :'SecretSheath::Account',
                 join_table: :accounts_child_keys,
                 left_key: :key_id, right_key: :accessor_id

    plugin :association_dependencies,
           accessor: :nullify

    plugin :timestamps
    plugin :uuid, field: :alias
    plugin :whitelist_security
    set_allowed_columns :name, :description, :content

    def type
      'childkey'
    end

    def owner
      parent.owner
    end

    def accessors
      accessor
    end

    def folder
      SharedFolder.new
    end

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
      self.short_alias = self.alias.to_s[0..7]
      self.name = "#{name}-#{short_alias}"
      super
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'childkey',
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
          owner:,
          accessor:
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
