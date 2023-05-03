# frozen_string_literal: true

require './require_app'
require_app

run SecretSheath::Api.freeze.app
