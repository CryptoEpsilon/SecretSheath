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
    def self.call(auth:, key:, secret_data:)
      raise NotFoundError unless key

      policy = KeyPolicy.new(auth[:account], key, auth[:scope])
      raise ForbiddenError unless policy.can_decrypt?

      encrypted_data = SecretData.new(secret_data)

      key_content = key.type == 'childkey' ? extract_childkey(auth[:account], key) : key.content
      encrypted_data.decrypt(key_content)
    end

    def self.extract_childkey(account, key)
      AsymetricCrypto.new(key.owner.public_key, account.private_key).decrypt(key.content)
    end

    def self.key
      @key = Base64.strict_decode64(@base_key)
    end
  end
end
