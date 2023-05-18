# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module SecretSheath
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_folders, class: :'SecretSheath::Folder', key: :owner_id

    many_to_many :sharers,
                 class: :'SecretSheath::Key',
                 join_table: :accounts_keys,
                 left_key: :sharer_id, right_key: :key_id

    plugin :association_dependencies,
           owned_folders: :destroy,
           sharers: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def before_save
      self.masterkey_salt = Base64.strict_encode64(Password.new_salt)
      super
    end

    def keys
      owned_folders + sharers
    end

    def masterkey_salt
      SecureDB.decrypt(masterkey_salt_encrypted)
    end

    def masterkey_salt=(plaintext)
      self.masterkey_salt_encrypted = SecureDB.encrypt(plaintext)
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = SecretSheath::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            id:,
            username:,
            email:
          }
        }, options
      )
    end
  end
end
