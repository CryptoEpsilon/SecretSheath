# frozen_string_literal: true

module SecretSheath
  # Add a accessor to another owner's existing key
  class AddAccessor
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as accessor'
      end
    end

    # Error key not found
    class KeyNotFound < StandardError
      def message
        'Key not found'
      end
    end

    def self.call(auth:, key:, accessor_email:) # rubocop:disable Metrics/MethodLength
      invitee = Account.first(email: accessor_email)
      policy = SharingRequestPolicy.new(
        key, auth[:account], invitee, auth[:scope]
      )

      raise ForbiddenError unless policy.can_invite?

      invitee_public_key = invitee.public_key
      owner_private_key = auth[:account].private_key
      childkey = key.add_child(
        name: key.name,
        description: "shared from #{auth[:account].username}",
        content: AsymetricCrypto.new(invitee_public_key, owner_private_key).encrypt(key.content)
      )
      childkey.add_accessor(invitee)
      # invitee
      childkey.full_details
    end
  end
end
