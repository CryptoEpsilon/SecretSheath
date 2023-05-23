# frozen_string_literal: true

module SecretSheath
  # Policy to determine if an account can view a particular key
  class SharingRequestPolicy
    def initialize(key, requestor_account, target_account)
      @key = key
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = KeyPolicy.new(requestor_account, key)
      @target = KeyPolicy.new(target_account, key)
    end

    def can_invite?
      @requestor.can_add_sharers? && @target.can_share?
    end

    def can_remove?
      @requestor.can_remove_sharers? && target_is_sharer?
    end

    private

    def target_is_sharer?
      @key.shared_keys.include?(@target_account)
    end
  end
end
