# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'HAPPY: should validate default full scope' do
    scope = AuthScope.new
    _(scope.can_read?('*')).must_equal(true)
    _(scope.can_write?('*')).must_equal(true)
    _(scope.can_encrypt?('*')).must_equal(true)
    _(scope.can_decrypt?('*')).must_equal(true)
  end

  it 'HAPPY: should validate read only scope' do
    scope = AuthScope.new(AuthScope::READ_ONLY)
    _(scope.can_read?('keys')).must_equal(true)
    _(scope.can_read?('folders')).must_equal(true)

    _(scope.can_write?('keys')).must_equal(false)
    _(scope.can_write?('folders')).must_equal(false)

    _(scope.can_encrypt?('keys')).must_equal(false)
    _(scope.can_decrypt?('keys')).must_equal(false)
  end

  it 'HAPPY: should validate encrypt only scope' do
    scope = AuthScope.new(AuthScope::ENCRYPT_ONLY)
    _(scope.can_read?('keys')).must_equal(true)
    _(scope.can_encrypt?('keys')).must_equal(true)
    _(scope.can_write?('keys')).must_equal(false)
    _(scope.can_decrypt?('keys')).must_equal(false)
  end

  it 'HAPPY: should validate decrypt only scope' do
    scope = AuthScope.new(AuthScope::DECRYPT_ONLY)
    _(scope.can_read?('keys')).must_equal(true)
    _(scope.can_decrypt?('keys')).must_equal(true)
    _(scope.can_write?('keys')).must_equal(false)
    _(scope.can_encrypt?('keys')).must_equal(false)
  end

  it 'HAPPY: should validate single limit scope' do
    scope = AuthScope.new('keys:test:encrypt keys:test:decrypt')
    _(scope.can_read?('keys', 'test')).must_equal(true)
    _(scope.can_encrypt?('keys', 'test')).must_equal(true)
    _(scope.can_decrypt?('keys', 'test')).must_equal(true)
    _(scope.can_write?('keys', 'test')).must_equal(false)
  end
end
