# frozen_string_literal: true
require_relative '../lib/auth_scope'

module SecretSheath
  # Policy to determine if account can view a project
  class KeyPolicy
    def initialize(account, key, auth_scope = nil)
      @account = account
      @key = key
      @auth_scope = auth_scope
      @resource_name = key.name
    end

    def can_view?
      can_read?(@resource_name) && (account_owns_key? || account_shares_on_key?)
    end

    def can_decrypt?
      can_decrypt_with?(@resource_name) && (account_owns_key? || account_shares_on_key?)
    end

    def can_encrypt?
      can_encrypt_with?(@resource_name) && account_owns_key?
    end

    def can_delete?
      can_write?(@resource_name) && account_owns_key?
    end

    def can_manage?
      can_write?(@resource_name) && account_owns_key?
    end

    def can_add_accessors?
      can_write?(@resource_name) && account_owns_key?
    end

    def can_get_accessors?
      can_read?(@resource_name) && (account_owns_key? || account_shares_on_key?)
    end

    def can_remove_accessors?
      can_write?(@resource_name) && account_owns_key?
    end

    def can_share?
      !(account_owns_key? or account_shares_on_key?)
    end

    def summary
      {
        can_view: can_view?,
        can_encrypt: can_encrypt?,
        can_decrypt: can_decrypt?,
        can_delete: can_delete?,
        can_add_accessors: can_add_accessors?,
        can_manage: can_manage?,
        can_remove_accessors: can_remove_accessors?,
        can_share: can_share?
      }
    end

    private

    def can_read?(resource_name)
      @auth_scope ? @auth_scope.can_read?('keys', resource_name) : false
    end

    def can_write?(resource_name)
      @auth_scope ? @auth_scope.can_write?('keys', resource_name) : false
    end

    def can_encrypt_with?(resource_name)
      @auth_scope ? @auth_scope.can_encrypt?('keys', resource_name) : false
    end

    def can_decrypt_with?(resource_name)
      @auth_scope ? @auth_scope.can_decrypt?('keys', resource_name) : false
    end

    def account_owns_key?
      @key.folder.owner == @account
    end

    def account_shares_on_key?
      @key.accessors.include?(@account)
    end
  end
end
