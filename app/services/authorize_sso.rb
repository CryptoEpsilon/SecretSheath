# frozen_string_literal: true

require 'http'

module SecretSheath
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    # Raised when no password is set for the account
    class RequirePassword < StandardError
      def message
        'Password required for this account'
      end
    end

    def call(access_token)
      github_account = get_github_account(access_token)
      sso_account = find_sso_account(github_account)

      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'SecretSheath',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['GITHUB_ACCOUNT_URL'])

      raise unless gh_response.status == 200

      account = GithubAccount.new(JSON.parse(gh_response))
      { username: account.username, email: account.email }
    end

    def find_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        { username: account_data[:username], email: account_data[:email], set_password: true }
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account:,
          registration_token: SecureMessage.encrypt(account)
        }
      }
    end
  end
end
