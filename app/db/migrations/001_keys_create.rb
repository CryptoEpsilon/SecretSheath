# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:keys) do
      primary_key :id

      String :folder_id, unique: true, null: false
      String :key_id, unique: true, null: false
	
	String :name
	String :content
    end
  end
end
