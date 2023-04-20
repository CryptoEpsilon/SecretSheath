# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'
require_relative '../app/lib/secure_db'

def wipe_database
  app.DB[:keys].delete
  app.DB[:folders].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:keys] = YAML.safe_load File.read('app/db/seeds/key_seeds.yml')
DATA[:folders] = YAML.safe_load File.read('app/db/seeds/folder_seeds.yml')
