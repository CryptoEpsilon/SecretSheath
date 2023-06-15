# frozen_string_literal: true

module SecretSheath
  # Add a accessor to another owner's existing key
  class DeleteAccessor
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as accessor'
      end
    end

    def self.call(auth:, key:, accessor_email:)
      invitee = Account.first(email: accessor_email)
      policy = SharingRequestPolicy.new(
        key, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      key.accessors(invitee).access.first.destroy
    end
  end
end
