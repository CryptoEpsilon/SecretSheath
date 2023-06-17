# frozen_string_literal: true

module SecretSheath
  # Add a collaborator to another owner's existing project
  class GetKeyQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that Key'
      end
    end

    # Error for cannot find a project
    class NotFoundError < StandardError
      def message
        'We could not find Key'
      end
    end

    # Key for given requestor account
    def self.call(auth:, key:)
      raise NotFoundError unless key

      policy = KeyPolicy.new(auth[:account], key, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      key.full_details.merge(policies: policy.summary)
    end
  end
end
