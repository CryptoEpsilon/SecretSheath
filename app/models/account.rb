# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module SecretSheath
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_folders, class: :'SecretSheath::Folder', key: :owner_id

    many_to_many :access,
                 class: :'SecretSheath::ChildKey',
                 join_table: :accounts_child_keys,
                 left_key: :accessor_id, right_key: :key_id

    plugin :association_dependencies,
           owned_folders: :destroy,
           access: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    def before_save
      asym_key = AsymetricCrypto.generate_keypair
      self.public_key = asym_key[:public_key]
      self.private_key = ProtectedKey.encrypt(asym_key[:private_key])
      ProtectedKey.forget
      super
    end

    def parent_keys
      owned_folders.map(&:keys).flatten
    end

    def children_keys
      owned_folders.keys.map(&:children).flatten
    end

    def shared_keys
      access
    end

    def public_key
      SecureDB.decrypt(public_key_encrypted)
    end

    def public_key=(plaintext)
      self.public_key_encrypted = SecureDB.encrypt(plaintext)
    end

    def private_key
      protected_priv64 = SecureDB.decrypt(private_key_encrypted)
      ProtectedKey.decrypt(protected_priv64)
    end

    def private_key=(plaintext)
      self.private_key_encrypted = SecureDB.encrypt(plaintext)
    end

    def masterkey_salt
      SecureDB.decrypt(masterkey_salt_encrypted)
    end

    def masterkey_salt=(plaintext)
      self.masterkey_salt_encrypted = SecureDB.encrypt(plaintext)
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
      self.masterkey_salt = Base64.strict_encode64(Password.new_salt)
      ProtectedKey.setup(assemble_masterkey(new_password))
    end

    def password?(try_password)
      digest = SecretSheath::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def assemble_masterkey(password)
      raise 'Password mismatch' unless password?(password)

      ConstructMasterkey.construct(
        encoded_salt: masterkey_salt,
        password:
      )
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

    def to_h = JSON.parse(to_json)
  end
end
