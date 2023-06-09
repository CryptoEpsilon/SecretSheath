# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id

      String :username, null: false, unique: true
      String :email, null: false, unique: true

      String :password_digest
      String :masterkey_salt_encrypted

      String :public_key_encrypted
      String :private_key_encrypted

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
