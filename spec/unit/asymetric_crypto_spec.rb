# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'HAPPY: should successfully encrypt' do
    key_a = AsymetricCrypto.generate_keypair
    key_b = AsymetricCrypto.generate_keypair

    data = 'test data'
    encrypted_data = AsymetricCrypto.new(key_a[:public_key], key_b[:private_key]).encrypt(data)

    _(encrypted_data).wont_be_nil
    _(encrypted_data).wont_equal data
  end

  it 'HAPPY: should successfully decrypt' do
    key_a = AsymetricCrypto.generate_keypair
    key_b = AsymetricCrypto.generate_keypair

    data = 'test data'
    encrypted_data = AsymetricCrypto.new(key_a[:public_key], key_b[:private_key]).encrypt(data)

    decrypted_data = AsymetricCrypto.new(key_b[:public_key], key_a[:private_key]).decrypt(encrypted_data)

    _(decrypted_data).wont_be_nil
    _(decrypted_data).must_equal data
  end
end
