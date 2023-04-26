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

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'folder',
            attributes: {
              id:,
              name:,
              description:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
