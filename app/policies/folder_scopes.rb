# frozen_string_literal: true

module SecretSheath
  # Policy to determine if account can view a key
  class FolderPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, auth_scope = nil, target_account = nil)
        target_account ||= current_account
        @auth_scope = auth_scope
        @full_scope = all_folders(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        @full_scope if @current_account == @target_account
      end

      private

      def all_folders(account)
        account.owned_folders.map do |folder|
          folder.to_h.merge(policies: FolderPolicy.new(account, folder, @auth_scope).summary)
        end
      end
    end
  end
end
