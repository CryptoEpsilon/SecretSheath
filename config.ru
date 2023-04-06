# frozen_string_literal: true

require './app/controllers/app'
run SecretSheath::Api.freeze.app
