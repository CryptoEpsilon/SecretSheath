# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:folders) do
      foreign_key :key_id, table: :keys

      String :name, null: false
      String :description
    end
  end
end
