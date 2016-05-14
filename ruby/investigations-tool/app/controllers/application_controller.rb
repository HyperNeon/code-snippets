class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, :get_investigations, :get_utilities
  
  def get_investigations
    @investigations = Investigation.select(:id, :name).order(:name)
  end
  
  def get_utilities
    @utilities = Utility.all.order(:code)
  end

  # Occurs when OAuth recognizes that client does not have correct access or Oauth request failed, it will try
  # to dump the old access token and request for a new one.
  rescue_from JIRA::OauthClient::UninitializedAccessTokenError do
    Rails.logger.info "Uninitialized access token for #{current_user.get_full_name}"
    session[:return_to] = request.url
    redirect_to new_jira_session_url
  end

  # Main controller method that should be used in controller actions that requires any JIRA access.
  def authorize_jira
    Rails.logger.info "Authorize JIRA for #{current_user.get_full_name}"
    JIRARuby.client_for_user!(current_user)
  end

  def search_jira_users
    begin
      render json: JiraAPIConnection.search_users(params[:username])
    rescue
      render json: "Something Went Wrong While Searching For Users"
    end
  end
end
