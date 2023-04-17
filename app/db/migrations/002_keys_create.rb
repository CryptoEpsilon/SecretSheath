# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:keys) do
      uuid :id, primary_key :true
      foreign_key :folder_id, table: :folders
      String :key_alias, unique: true, null: false
      String :name
      String :description_secure
      String :content_secure, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
