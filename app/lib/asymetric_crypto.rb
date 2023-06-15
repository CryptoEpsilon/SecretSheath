# frozen_string_literal: true

require 'rbnacl'
require 'base64'

# Asymetric encryption and decryption
class AsymetricCrypto
  attr_reader :private_key, :public_key, :private_raw, :public_raw

  def initialize(public_key, private_key)
    @private_key = Base64.strict_decode64(private_key)
    @public_key = Base64.strict_decode64(public_key)
  end

  def self.generate_keypair
    private_key = RbNaCl::PrivateKey.generate
    public_key = private_key.public_key
    {
      private_key: Base64.strict_encode64(private_key),
      public_key: Base64.strict_encode64(public_key)
    }
  end

  def encrypt(plaintext)
    encrypt_box = RbNaCl::SimpleBox.from_keypair(
      @public_key,
      @private_key
    )
    ciphertext = encrypt_box.encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  end

  def decrypt(ciphertext)
    decoded_cipher = Base64.strict_decode64(ciphertext)
    decrypt_box = RbNaCl::SimpleBox.from_keypair(
      @public_key,
      @private_key
    )
    plaintext = decrypt_box.decrypt(decoded_cipher)
    plaintext.force_encoding('UTF-8')
  end
end
