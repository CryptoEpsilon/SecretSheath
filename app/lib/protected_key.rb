# frozen_string_literal: true

require_relative 'securable'

# Encrypt and Decrypt from Database
class ProtectedKey
  extend Securable

  # Encrypt or else return nil if data is nil

  def self.key
    @key = Base64.strict_decode64(@base_key)
  end

  def self.encrypt(plaintext)
    return nil unless plaintext

    ciphertext = base_encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  end

  # Decrypt or else return nil if database value is nil already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.strict_decode64(ciphertext64)
    base_decrypt(ciphertext)
  end
end
