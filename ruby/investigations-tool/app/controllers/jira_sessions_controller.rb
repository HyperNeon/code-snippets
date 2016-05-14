class JiraSessionsController < ApplicationController
  before_filter :authorize_jira

  def new
    Rails.logger.info 'Asking for new token'
    request_token = JIRARuby.client.request_token(oauth_callback: callback_url)
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def authorize
    Rails.logger.info 'Authorize callback'
    JIRARuby.client.set_request_token(
        session[:request_token], session[:request_secret]
    )
    access_token = JIRARuby.client.init_access_token(
        oauth_verifier: params[:oauth_verifier]
    )

    current_user.jira_access_token = access_token.token
    current_user.jira_access_key = access_token.secret
    current_user.save

    session.delete(:request_token)
    session.delete(:request_secret)

    redirect_to session[:return_to]
  end

  private

  def callback_url
    [request.protocol, request.host_with_port, JIRARuby::JIRA_CALLBACK_ENDPOINT].join('')
  end
end