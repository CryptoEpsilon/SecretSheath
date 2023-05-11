# frozen_string_literal: true

module SecretSheath
  # Add a sharer to another owner's key
  class AddSharerToKey
    # Error for owner cannot be sharer
    class OwnerNotSharerError < StandardError
      def message = 'Owner cannot be sharer of key'
    end

    def self.call(email:, key_id:)
      # binding.pry
      sharer = Account.first(email:)
      key = Key.first(id: key_id)
      raise(OwnerNotSharerError) if key.folder.owner_id == sharer.id

      key.add_shared_key(sharer)
    end
  end
end
