class TicketController < ApplicationController
  def index
    if current_user.jira_access_token.nil? || current_user.jira_access_key.nil?
      session[:return_to] = request.url
      redirect_to new_jira_session_url and return
    end
    @issues = Issue.where(ticket_number: params[:ticket])
    if @issues.size == 1
      redirect_to issue_url(id: @issues.first.id)
    else
      begin
        @ticket_data = Issue.get_ticket_data(params[:ticket])
        @issue_transitions = Issue.get_ticket_transitions(current_user, params[:ticket])
        @resolutions = ["Fixed", "Won't Fix", "Duplicate", "Incomplete", "Invalid", "Cannot Reproduce", "Done"]
      rescue JIRA::HTTPError
        @ticket_Data = nil
      end
    end
  end
end
