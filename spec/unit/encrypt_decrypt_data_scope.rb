# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Encrypt Data' do
  before do
    wipe_database

    account = SecretSheath::Account.create(username: 'test', password: 'passrand', email: 'test@mail.com')
    ProtectedKey.setup(account.assemble_masterkey('passrand'))
    account.add_owned_folder(name: 'test').add_key(name: 'test')
  end

  it 'HAPPY: should encrypt data with valid key' do
    plaintext_data = 'This is a test'
    expire_in = 0
    account = SecretSheath::Account.first(username: 'test')
    key = account.parent_keys.first

    encrypted_data = SecretSheath::EncryptData.call(
      auth: { account:, scope: AuthScope.new },
      key:,
      plaintext_data:,
      expire_in:
    )
    _(encrypted_data[:attributes][:ciphertext]).wont_be_nil
    _(encrypted_data[:attributes][:ciphertext]).wont_equal(plaintext_data)
  end

  it 'BAD: should not encrypt data with invalid key' do
    ProtectedKey.forget
    plaintext_data = 'This is a test'
    expire_in = 0
    account = SecretSheath::Account.first(username: 'test')
    key = account.parent_keys.first

    _(proc {
      SecretSheath::EncryptData.call(
        auth: { account:, scope: AuthScope.new },
        key:,
        plaintext_data:,
        expire_in:
      )
    }).must_raise
  end

  it 'HAPPY: should decrypt data with valid key' do
    plaintext_data = 'This is a test'
    expire_in = 0
    account = SecretSheath::Account.first(username: 'test')
    key = account.parent_keys.first

    encrypted_data = SecretSheath::EncryptData.call(
      auth: { account:, scope: AuthScope.new },
      key:,
      plaintext_data:,
      expire_in:
    )
    decrypted_data = SecretSheath::DecryptData.call(
      auth: { account:, scope: AuthScope.new },
      key:,
      secret_data: encrypted_data[:attributes][:ciphertext]
    )
    _(decrypted_data[:attributes][:plaintext]).must_equal(plaintext_data)
  end

  it 'BAD: should not decrypt data with invalid key' do
    plaintext_data = 'This is a test'
    expire_in = 0
    account = SecretSheath::Account.first(username: 'test')
    key = account.parent_keys.first

    encrypted_data = SecretSheath::EncryptData.call(
      auth: { account:, scope: AuthScope.new },
      key:,
      plaintext_data:,
      expire_in:
    )
    ProtectedKey.forget

    _(proc {
      SecretSheath::DecryptData.call(
        auth: { account:, scope: AuthScope.new },
        key:,
        secret_data: encrypted_data[:attributes][:ciphertext]
      )
    }).must_raise
  end

  it 'SAD: should not decrypt data with invalid ciphertext' do
    _(proc {
      SecretSheath::DecryptData.call(
        auth: { account:, scope: AuthScope.new },
        key:,
        secret_data: { attributes: { ciphertext: 'invalid' } }
      )
    }).must_raise
  end

  it 'SAD: should not decrpyt expired data' do
    plaintext_data = 'This is a test'
    expire_in = 1
    account = SecretSheath::Account.first(username: 'test')
    key = account.parent_keys.first

    encrypted_data = SecretSheath::EncryptData.call(
      auth: { account:, scope: AuthScope.new },
      key:,
      plaintext_data:,
      expire_in:
    )
    sleep(2)
    _(proc {
      SecretSheath::DecryptData.call(
        auth: { account:, scope: AuthScope.new },
        key:,
        secret_data: encrypted_data[:attributes][:ciphertext]
      )
    }).must_raise
  end
end
