# frozen_string_literal: true

require_relative '../lib/securable'

module SecretSheath
  # Add a collaborator to another owner's existing project
  class DecryptData
    extend Securable
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
    def self.call(account:, key:, ciphertext_data:)
      raise NotFoundError unless key

      policy = KeyPolicy.new(account, key)
      raise ForbiddenError unless policy.can_decrypt?

      setup(key.content)
      plaintext64 = Base64.strict_decode64(ciphertext_data)
      plaintext = base_decrypt(plaintext64)

      { type: 'decrypted_data', attributes: { plaintext: } }
    end

    def self.key
      @key = Base64.strict_decode64(@base_key)
    end
  end
end
