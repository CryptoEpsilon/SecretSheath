# frozen_string_literal: true

require_relative './spec_helper'

describe 'Secret credentials not exposed' do
  it 'HAPPY: should not find database url' do
    _(SecretSheath::Api.config.DATABASE_URL).must_be_nil
  end

  it 'HAPPY: should not find database key' do
    _(SecretSheath::Api.config.DB_KEY).must_be_nil
  end

  it 'HAPPY: should not find message key' do
    _(SecretSheath::Api.config.WEBAP_MSG_KEY).must_be_nil
  end
end
