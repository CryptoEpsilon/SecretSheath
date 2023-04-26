# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digest' do
    password = 'this is a password'
    digest = SecretSheath::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully check a valid password' do
    password = 'this is a password'
    digest_s = SecretSheath::Password.digest(password).to_s

    digest = SecretSheath::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully check an invalid password' do
    password = 'This is a password'
    try_password = 'It looks like a password'
    digest_s = SecretSheath::Password.digest(password).to_s

    digest = SecretSheath::Password.from_digest(digest_s)
    _(digest.correct?(try_password)).must_equal false
  end
end
