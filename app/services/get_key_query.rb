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
        'We could not find that Key'
      end
    end

    # Key for given requestor account
    def self.call(requestor:, Key:)
      raise NotFoundError unless Key

      policy = KeyPolicy.new(requestor, Key)
      raise ForbiddenError unless policy.can_view?

      key
    end
  end
end
