# frozen_string_literal: true

require 'json'
require 'sequel'

module SecretSheath
  # Model for a Folder
  class Folder < Sequel::Model
    one_to_many :keys
    plugin :association_dependencies, keys: :destroy
    plugin :timestamps

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
