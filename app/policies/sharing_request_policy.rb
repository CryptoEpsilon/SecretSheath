# frozen_string_literal: true

module SecretSheath
  # Policy to determine if an account can view a particular key
  class SharingRequestPolicy
    def initialize(key, requestor_account, target_account, auth_scope = nil)
      @key = key
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = KeyPolicy.new(requestor_account, key, auth_scope)
      @target = KeyPolicy.new(target_account, key, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_accessors? && @target.can_share?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_accessors? && target_is_accessor?)
    end

    def can_get_accessors?
      can_write? &&
        @requestor.can_get_accessors?
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('folders') : false
    end

    def target_is_accessor?
      @key.accessors.include?(@target_account)
    end
  end
end
