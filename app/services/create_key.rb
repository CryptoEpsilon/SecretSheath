# frozen_string_literal: true

module SecretSheath
  # Add Key to a Folder
  class CreateKey
    # Error for access denied
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more keys'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a key with those attributes'
      end
    end

    def self.call(auth:, folder:, key_data:)
      policy = FolderPolicy.new(auth[:account], folder, auth[:scope])
      raise ForbiddenError unless policy.can_add_keys?

      folder.add_key(key_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
