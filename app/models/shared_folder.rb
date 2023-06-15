# frozen_string_literal: true

require 'json'
require 'sequel'

module SecretSheath
  # Model for a Folder
  class SharedFolder

    def initialize(account = nil)
      @account = account
    end

    def name
      'Shared'
    end

    def owner
      @account
    end

    def to_h
      {
        type: 'folder',
        attributes: {
          id: 'shared',
          name:,
          description: 'Folder for shared keys'
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner: @account,
          keys: @account.access
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
