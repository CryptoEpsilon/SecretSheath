module SecretSheath
  
  class CreateKey
   
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more keys'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a key with those attributes'
      end
    end

    def self.call(account:, folder:, key_data:)
      policy = FolderPolicy.new(account, folder)
      raise ForbiddenError unless policy.can_add_keys?

      add_key(folder, key_data)
    end

    def self.add_key(folder, key_data)
      folder.add_key(key_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
