module JIRARuby
  mattr_accessor :client

  JIRA_PRODOP_PROJECT_LINK = "https:///REDACTED//issues/?jql=project%20%3D%20/REDACTED/"
  JIRA_SITE = 'https:///REDACTED/'
  JIRA_CONSUMER_KEY = '/REDACTED/'

  if Rails.env.development? || Rails.env.test?
    JIRA_KEY_LOCATION = Rails.root.join('config', 'jiraOauthPrivateKey.pem')
  else
    JIRA_KEY_LOCATION = '/REDACTED/'
  end
  JIRA_CALLBACK_ENDPOINT = '/authorize'

  blank_cred = {"username" => "", "password" => ""}

  begin
    if Rails.env.development?
      jira_cred = JSON.parse(File.read(Rails.root.join("config", "jira_credentials.json")))
    elsif Rails.env.alpha?
      jira_cred = JSON.parse(File.read("/REDACTED/"))
    else
      jira_cred = JSON.parse(File.read("/REDACTED/"))
    end
  rescue
    jira_cred = blank_cred
  end

  username = jira_cred["username"]
  password = jira_cred["password"]
  JIRA_OPTIONS = { :username => username, :password => password, :site => JIRA_SITE, :context_path => '', :auth_type => :basic}

  class << self
    def client_for_user!(user)
      self.client = begin
        Rails.logger.info "Creating JIRA client for #{user.email}"
        options = {
            private_key_file: JIRA_KEY_LOCATION,
            consumer_key: JIRA_CONSUMER_KEY,
            site: JIRA_SITE,
            rest_base_path: '/rest/api/2',
            context_path: '',
            use_ssl: false,
            openssl_verify_mode: 'none',
            signature_method: 'RSA-SHA1',
            scheme: :header,
            request_token_path: '/plugins/servlet/oauth/request-token',
            access_token_path: '/plugins/servlet/oauth/access-token',
            authorize_path: '/plugins/servlet/oauth/authorize'
        }
        client = JIRA::Client.new(options)

        # Add access token if authorized previously
        if jira_session?(user)
          Rails.logger.info 'Setting access to Jira'
          client.set_access_token(user.jira_access_token, user.jira_access_key)
        end
        client
      end
    end

    def jira_session?(user)
      Rails.logger.info "#{user.get_full_name}'s access_token: #{user.jira_access_token.inspect}"
      Rails.logger.info "#{user.get_full_name}'s access_key: #{user.jira_access_key.inspect}"
      user.jira_access_token.present? && user.jira_access_key.present?
    end
  end
end