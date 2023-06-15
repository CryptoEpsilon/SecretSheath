# frozen_string_literal: true

module SecretSheath
  # Add a collaborator to another owner's existing project
  class DeleteKey
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that key'
      end
    end

    # Error for cannot find a key
    class NotFoundError < StandardError
      def message
        'We could not find that key'
      end
    end

    def self.call(auth:, key:)
      raise NotFoundError unless key

      policy = KeyPolicy.new(auth[:account], key, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      key.destroy
    end
  end
end
