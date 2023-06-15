# frozen_string_literal: true

module SecretSheath
  # Policy to determine if account can view a key
  class KeyPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_keys(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |key|
            includes_accessor?(key, @current_account)
          end
        end
      end

      private

      def all_keys(account)
        account.owned_folders.keys + account.acess
      end

      def includes_accessor?(key, account)
        key.acessors.include? account
      end
    end
  end
end
