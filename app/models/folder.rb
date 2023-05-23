# frozen_string_literal: true

require 'json'
require 'sequel'

module SecretSheath
  # Model for a Folder
  class Folder < Sequel::Model
    many_to_one :owner, class: :'SecretSheath::Account'

    one_to_many :keys

    plugin :association_dependencies,
           keys: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    def description
      SecureDB.decrypt(description_encrypted)
    end

    def description=(plaintext)
      self.description_encrypted = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
       type: 'folder',
       attributes: {
         id:,
         name:,
         description:
       }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          keys:
        }
      )
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(to_h, options)
    end
    # rubocop:enable Metrics/MethodLength
  end
end

