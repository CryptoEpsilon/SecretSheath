# frozen_string_literal: true

module SecretSheath
  # Add a accessor to another owner's existing key
  class GetAccessorQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as accessor'
      end
    end

    def self.call(auth:, key:)
      policy = KeyPolicy.new(
        auth[:account], key, auth[:scope]
      )
      raise ForbiddenError unless policy.can_get_accessors?

      key.shared_with
    end
  end
end
