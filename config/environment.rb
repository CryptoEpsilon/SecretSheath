# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require 'rack/ssl-enforcer'
require_app('lib')

module SecretSheath
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Enforce SSL
      configure :production do
        use Rack::SslEnforcer, hsts: true
      end

      # HTTP Request logging
      configure :development, :production do
        plugin :common_logger, $stdout
      end

      # Custom events logging
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
      AuthToken.setup(ENV.fetch('MSG_KEY')) # Load crypto key
    end

    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
