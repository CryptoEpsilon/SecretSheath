# frozen_string_literal: true

module SecretSheath
  # Service object to create a new folder for an owner
  class CreateFolderForOwner
    # Error for access forbidden
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more folder'
      end
    end

    class DuplicateFolderError < StandardError
      def message
        'Folder already exists'
      end
    end

    def self.call(auth:, folder_data:)
      raise DuplicateFolderError if auth[:account].owned_folders.find { |f| f.name == folder_data['name'] }
      raise ForbiddenError unless auth[:scope].can_write?('folders', folder_data['name'])

      auth[:account].add_owned_folder(folder_data)
    end
  end
end
