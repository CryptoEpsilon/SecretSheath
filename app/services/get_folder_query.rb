# frozen_string_literal: true

module SecretSheath
  # Add a collaborator to another owner's existing project
  class GetFolderQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that Folder'
      end
    end

    # Error for cannot find a Folder
    class NotFoundError < StandardError
      def message
        'We could not find that Folder'
      end
    end

    def self.call(account:, folder:)
      raise NotFoundError unless folder

      policy = FolderPolicy.new(account, folder)
      raise ForbiddenError unless policy.can_view?

      folder.full_details.merge(policies: policy.summary)
    end
  end
end
