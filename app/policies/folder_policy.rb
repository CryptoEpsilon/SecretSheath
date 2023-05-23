# frozen_string_literal: true

module SecretSheath
  # Policy to determine if an account can view a particular folder
  class FolderPolicy
    def initialize(account, folder)
      @account = account
      @folder = folder
    end

    def can_view?
      account_is_owner?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_add_keys?
      account_is_owner?
    end

    def can_remove_keys?
      account_is_owner? 
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

    def account_is_owner?
      @folder.owner == @account
    end

  end
end
