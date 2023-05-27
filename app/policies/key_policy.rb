# frozen_string_literal: true

module SecretSheath
  # Policy to determine if account can view a project
  class KeyPolicy
    def initialize(account, key, auth_scope = nil)
      @account = account
      @key = key
      @auth_scope = auth_scope
    end

    def can_view?
       can_read? && (account_owns_key? || account_shares_on_key?)
    end

    def can_encrypt?
      can_write? && (account_owns_key? || account_shares_on_key?)
    end

    def can_decrypt?
      can_write? && (account_owns_key? || account_shares_on_key?)
    end

    def can_edit?
      can_write? && account_owns_key?
    end

    def can_delete?
      can_write? && account_owns_key?
    end

    def can_add_sharers?
      can_write? && account_owns_key?
    end

    def can_remove_sharers?
      can_write? &&account_owns_key?
    end

    def can_share?
      !(account_owns_key? or account_shares_on_key?)
    end

    def summary
      {
        can_view: can_view?,
        can_encrypt: can_encrypt?,
        can_decrypt: can_decrypt?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_sharers: can_add_sharers?,
        can_remove_sharers: can_remove_sharers?,
        can_share: can_share?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('keys') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('keys') : false
    end

    def account_owns_key?
      @key.folder.owner == @account
    end

    def account_shares_on_key?
      @key.shared_keys.include?(@account)
    end
  end
end
