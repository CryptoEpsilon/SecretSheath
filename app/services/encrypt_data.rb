# frozen_string_literal: true

require_relative '../lib/securable'

module SecretSheath
  # Add a collaborator to another owner's existing project
  class EncryptData

    ONE_HOUR = 60 * 60
    ONE_DAY = ONE_HOUR * 24
    ONE_WEEK = ONE_DAY * 7
    ONE_MONTH = ONE_WEEK * 4
    ONE_YEAR = ONE_MONTH * 12

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
    def self.call(auth:, key:, plaintext_data:, valid_to: ONE_WEEK)
      raise NotFoundError unless key

      policy = KeyPolicy.new(auth[:account], key, auth[:scope])
      raise ForbiddenError unless policy.can_encrypt?

      SecretData.encrypt(plaintext_data, key, valid_to)
    end

    def self.key
      @key = Base64.strict_decode64(@base_key)
    end
  end
end
