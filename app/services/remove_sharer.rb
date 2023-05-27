# frozen_string_literal: true

module SecretSheath
  # Remove a sharer to another owner's existing key
  class RemoveSharer
    # Error for owner cannot be sharer
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, sharer_email:, key_id:)
      key = Key.first(id: key_id)
      sharer = Account.first(email: sharer_email)

      policy = SharingRequestPolicy.new(
        key, auth[:account], sharer, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      key.remove_shared_keys(sharer)
      sharer
    end
  end
end
