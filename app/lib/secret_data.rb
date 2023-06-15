# frozen_string_literal: true

require 'base64'
require_relative 'securable'

# Token and Detokenize secret information
class SecretData
  extend Securable

  # Exception for invalid secret
  class InvalidSecretError < StandardError
    def message
      'Invalid secret'
    end
  end

  def initialize(secret)
    @secret = secret
    contents = SecretData.detokenize(@secret)
    @ciphertext = contents['ciphertext']
    @expiration = contents['exp']
  end

  def self.encrypt(secret, key, expiration = 0)
    raise InvalidSecretError unless secret

    setup(key.content)
    ciphertext = base_encrypt(secret)
    ciphertext64 = Base64.strict_encode64(ciphertext)
    tokenized_data = tokenize(
      ciphertext: ciphertext64,
      exp: expires(expiration)
    )
    { type: 'encrypted_data', attributes: { ciphertext: tokenized_data } }
  end

  def decrypt(key)
    raise InvalidSecretError if expired?

    SecretData.setup(key)
    plaintext64 = Base64.strict_decode64(@ciphertext)
    plaintext = SecretData.base_decrypt(plaintext64)

    { type: 'decrypted_data', attributes: { plaintext: } }
  rescue ArgumentError => e
    raise InvalidSecretError, e.message
  end

  def self.key
    @key = Base64.strict_decode64(@base_key)
  end

  def self.tokenize(message)
    return nil unless message

    message_json = message.to_json
    ciphertext = base_encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    message_json = base_decrypt(ciphertext)
    JSON.parse(message_json)
  rescue ArgumentError => e
    raise InvalidSecretError, e.message
  end

  def self.expires(expiration)
    expiration.positive? ? (Time.now + expiration).to_i : 0
  end

  def expired?
    @expiration.zero? ? false : Time.now > Time.at(@expiration)
  end

  def valid? = !expired?
end
