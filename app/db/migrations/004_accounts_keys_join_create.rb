# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(sharer_id: :accounts, key_id: :keys)
  end
end
