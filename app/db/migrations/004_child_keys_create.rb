# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:child_keys) do
      primary_key :id
      foreign_key :parent_id, table: :keys

      uuid :alias, null: false
      String :short_alias, null: false
      String :name
      String :content_encrypted, null: false
      String :description_encrypted

      int :limit
      int :offset

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
