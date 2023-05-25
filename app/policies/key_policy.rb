# frozen_string_literal: true

module SecretSheath
  # Policy to determine if account can view a project
  class KeyPolicy
    def initialize(account, key)
      @account = account
      @key = key
    end

    def can_view?
      account_owns_key? || account_shares_on_key?
    end

    def can_encrypt?
      account_owns_key? || account_shares_on_key?
    end

    def can_decrypt?
      account_owns_key? || account_shares_on_key?
    end

    def can_edit?
      account_owns_key?
    end

    def can_delete?
      account_owns_key?
    end

    def can_add_sharers?
      account_owns_key?
    end

    def can_remove_sharers?
      account_owns_key?
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

    def account_owns_key?
      @key.folder.owner == @account
    end

    def account_shares_on_key?
      @key.shared_keys.include?(@account)
    end
  end
end