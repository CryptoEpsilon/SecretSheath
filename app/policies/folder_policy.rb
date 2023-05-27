# frozen_string_literal: true

module SecretSheath
  # Policy to determine if an account can view a particular folder
  class FolderPolicy
    def initialize(account, folder, auth_scope = nil)
      @account = account
      @folder = folder
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && account_is_owner?
    end

    # duplication is ok!
    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_add_keys?
      can_write? && account_is_owner?
    end

    def can_remove_keys?
      can_write? && account_is_owner?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_keys: can_add_keys?,
        can_delete_keys: can_remove_keys?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('folders') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('folders') : false
    end

    def account_is_owner?
      @folder.owner == @account
    end

  end
end
