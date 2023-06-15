# frozen_string_literal: true

# Scopes for AuthTokens
class AuthScope
  ALL = '*'
  READ = 'read'
  WRITE = 'write'
  ENCRYPT = 'encrypt'
  DECRYPT = 'decrypt'

  EVERYTHING = '::write'
  READ_ONLY = '::read'
  ENCRYPT_ONLY = '::encrypt'
  DECRYPT_ONLY = '::decrypt'
  ENCRYPT_AND_DECRYPT = '::encrypt ::decrypt'

  SEPARATOR = ' '
  DIVIDER = ':'

  def initialize(scopes = EVERYTHING)
    @scopes_str = scopes
    @scopes = {}
    @resource_perm = {}
    scopes.split(SEPARATOR).each { |scope| add_scope(scope) }
  end

  def can_read?(resource, resource_name = ALL)
    readable?(ALL) || readable?(resource, resource_name)
  end

  def can_write?(resource, resource_name = ALL)
    writeable?(ALL) || writeable?(resource, resource_name)
  end

  def can_encrypt?(resource, resource_name = ALL)
    encryptable?(ALL) || encryptable?(resource, resource_name)
  end

  def can_decrypt?(resource, resource_name = ALL)
    decryptable?(ALL) || decryptable?(resource, resource_name)
  end

  def to_s
    @scopes_str
  end

  private

  def readable?(resource, resource_name = ALL)
    writeable?(resource, resource_name) || encryptable?(resource, resource_name) ||
      decryptable?(resource, resource_name) || permission_granted?(resource, resource_name, READ)
  end

  def encryptable?(resource, resource_name = ALL)
    writeable?(resource, resource_name) || permission_granted?(resource, resource_name, ENCRYPT)
  end

  def decryptable?(resource, resource_name = ALL)
    writeable?(resource, resource_name) || permission_granted?(resource, resource_name, DECRYPT)
  end

  def writeable?(resource, resource_name = ALL)
    permission_granted?(resource, resource_name, WRITE)
  end

  def permission_granted?(resource, resource_name, permission)
    return false unless @scopes[resource]
    return true if @scopes[resource][permission]&.include?(ALL)

    @scopes[resource][permission]&.include?(resource_name) ? true : false
  end

  def add_scope(scope)
    resource, resource_name, permission = scope.split(DIVIDER)
    resource = ALL if resource == ''
    resource_name = ALL if resource_name == ''

    @resource_perm[permission] ||= []
    @resource_perm[permission] << resource_name
    @scopes[resource] = @resource_perm
  end
end
