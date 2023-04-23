# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:keys) do
      uuid :id, primary_key: true
      foreign_key :folder_id, table: :folders

      String :alias, unique: true, null: false
      String :name
      String :description_encrypted
      String :content_encrypted, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end