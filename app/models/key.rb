# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Credence
  STORE_DIR = 'app/db/store'

  # Holds a full secret document
  class Key
    # Create a new document by passing in hash of attributes
    def initialize(new_key)
      @id          = new_key['id'] || new_id
      @filename    = new_key['filename']
      @description = new_key['description']
      @content     = new_key['content']
      @secretkey         = new_key['key'] || new_secretkey
    end

    attr_reader :id, :filename, :description, :content, :secretkey

    def to_json(options = {})
      JSON(
        {
          type: 'key',
          id:,
          filename:,
          description:,
          content:,
          secretkey:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Credence::STORE_DIR) unless Dir.exist? Credence::STORE_DIR
    end

    # Stores document in file store
    def save
      File.write("#{Credence::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      key_file = File.read("#{Credence::STORE_DIR}/#{find_id}.txt")
      Key.new JSON.parse(key_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{Credence::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Credence::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
    
    def new_secretkey
      secret_key = Base64.urlsafe_encode64(RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes))
    end
  end
end


