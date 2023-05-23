# frozen_string_literal: true

module SecretSheath
  # Add a Sharer to another owner's existing key
  class AddSharer
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as sharer'
      end
    end

    def self.call(account:, key:, sharer_email:)
      invitee = Account.first(email: sharer_email)
      policy = SharingRequestPolicy.new(key, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      key.add_shared_key(invitee)
      invitee
    end
  end
end
