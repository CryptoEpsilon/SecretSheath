# frozen_string_literal: true

require 'rbnacl'

module SecretSheath
  # Contruct master key from password
  class ConstructMasterkey
    def self.call(encoded_salt:, password:)
      opslimit = 2**20
      memlimit = 2**24
      digest_size = 32

      salt = Base64.strict_decode64(encoded_salt)
      Base64.strict_encode64(RbNaCl::PasswordHash.scrypt(
                               password, salt,
                               opslimit, memlimit, digest_size
                             ))
    end
  end
end
