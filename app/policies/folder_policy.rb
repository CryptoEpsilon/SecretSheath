# frozen_string_literal: true

require_relative '../lib/auth_scope'

module SecretSheath
  # Policy to determine if an account can view a particular folder
  class FolderPolicy
    def initialize(account, folder, auth_scope = nil)
      @account = account
      @folder = folder
      @auth_scope = auth_scope
      @resource_name = folder.name
    end

    def can_view?
      can_read?(@resource_name) && account_is_owner?
    end

    # duplication is ok!
    def can_edit?
      can_write?(@resource_name) && account_is_owner? && !folder_is_shared?
    end

    def can_delete?
      can_write?(@resource_name) && account_is_owner? && !folder_is_shared?
    end

    def can_add_keys?
      can_write?(@resource_name) && account_is_owner? && !folder_is_shared?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_keys: can_add_keys?
      }
    end

    private

    def can_read?(resource_name)
      @auth_scope ? @auth_scope.can_read?('folders', resource_name) : false
    end

    def can_write?(resource_name)
      @auth_scope ? @auth_scope.can_write?('folders', resource_name) : false
    end

    def account_is_owner?
      @folder.owner == @account
    end

    def folder_is_shared?
      @folder.name == 'Shared'
    end
  end
end
