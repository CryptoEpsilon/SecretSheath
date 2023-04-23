# frozen_string_literal: true

module SecretSheath
  # Service object to create a new folder for an owner
  class CreateFolderForOwner
    def self.call(owner_id:, folder_data:)
      Account.find(id: owner_id)
             .add_owned_folder(folder_data)
    end
  end
end
