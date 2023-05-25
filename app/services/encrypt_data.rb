# frozen_string_literal: true

require_relative '../lib/securable'

module SecretSheath
  # Add a collaborator to another owner's existing project
  class EncryptData
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
    def self.call(account:, key:, plaintext_data:)
      raise NotFoundError unless key

      policy = KeyPolicy.new(account, key)
      raise ForbiddenError unless policy.can_encrypt?

      setup(key.content)
      ciphertext = base_encrypt(plaintext_data)
      ciphertext64 = Base64.strict_encode64(ciphertext)

      { type: 'encrypted_data', attributes: { ciphertext: ciphertext64 } }
    end

    def self.key
      @key = Base64.strict_decode64(@base_key)
    end
  end
end
