# frozen_string_literal: true

module SecretSheath
  # Create new configuration for a project
  class CreateKeyForFolder
    def self.call(folder_id:, key_data:)
      Folder.first(id: folder_id)
            .add_key(key_data)
    end
  end
end
