# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:keys) do
      primary_key :id
      foreign_key :folder_id, table: :folders

      uuid :alias, null: false
      String :short_alias, null: false
      String :name
      String :description_encrypted
      String :content_encrypted, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
