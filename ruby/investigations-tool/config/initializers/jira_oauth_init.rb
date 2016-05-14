JIRA::OauthClient.class_eval do
  # Returns the current request token if it is set, else it creates
  # and sets a new token.
  def request_token(options = {}, *arguments, &block)
    @request_token ||= get_request_token(options, *arguments, block)
  end
end