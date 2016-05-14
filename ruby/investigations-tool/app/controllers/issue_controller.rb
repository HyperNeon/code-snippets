class IssueController < ApplicationController
  respond_to :html, :js

  def index
    if current_user.jira_access_token.nil? || current_user.jira_access_key.nil?
      session[:return_to] = request.url
      redirect_to new_jira_session_url and return
    end
    @issue = Issue.find(params[:id])
    @queries = ITQuery.get_available_queries
    begin
      @issue_data = @issue.get_issue_data
      @issue_transitions = @issue.get_transitions(current_user)
      @resolutions = ["Fixed", "Won't Fix", "Duplicate", "Incomplete", "Invalid", "Cannot Reproduce", "Done"]
    rescue JIRA::HTTPError => e
      # A deleted ticket was found while trying to load the page. Should get taken care of on the next refresh
      @issue_data = nil
    end
  end
  
  def show_query_details
    queries = JSON.parse params[:queries]
    @query = queries.detect {|q| q["name"] == params[:query_index]}
    @id = params[:id]
  end
  
  def run_query
    @issue = Issue.find(params[:id])
    @query = JSON.parse params[:query]
    method = @query["method"]
    if @query["options"]
      options = @query["options"].inject({}) {|hash, opt| hash[opt] = params["option-#{opt}".to_sym]; hash}
    else
      options = {}
    end

    uuid = options['uuid']
    if params[:query_id].present?
     uuid = params[:query_id]
    end

    @response = @issue.run_query(method: method, query: @query, options: options, uuid: uuid)
  end
  
  def mark_as_viewed
    Issue.find(params[:id]).mark_as_viewed
    redirect_to :back
  end

  def assign_ticket
    assignee = params[:assignee]
    ticket_number = params[:ticket]
    comment = params[:comment]
    begin
      Issue.assign(ticket_number, current_user, assignee, comment)
      redirect_to :back
    rescue JIRA::HTTPError => e
      redirect_to :back, alert: "The following error was received while trying to change the assignee: #{e.to_s}: #{e.response}"
    end
  end

  def post_results_as_comment
    issue = Issue.find(params[:id])
    table = JSON.parse params[:table_json]
    optional_comment = params[:optional_comment]
    comment = optional_comment + "\n ---- \n"
    comment += "||"
    table.shift.keys.each {|key| comment = comment + key + "||"}
    comment += "\n"
    table.each do |row|
      comment += "|"
      row.values.each {|value| comment = comment + value + "|" }
      comment += "\n"
    end
    comment += "This table was posted from *Investigations Tool* at [https:///REDACTED//issue/#{issue.id}/index]"
    begin
      issue.post_comment(current_user, comment)
      @jira_post_result = true
    rescue JIRA::HTTPError => e
      @jira_post_result = false
    end
  end

  def update_status
    status_id = params[:status_id]
    ticket_number = params[:ticket]
    resolution = params[:resolution]
    comment = params[:comment]
    begin
      Issue.update_status(ticket_number, current_user, status_id, resolution, comment)
      redirect_to :back
    rescue JIRA::HTTPError => e
      redirect_to :back, alert: "The following error was received while trying to update the status: #{e.to_s}: #{e.response}"
    end
  end

  def start_timer
    summary = params[:summary]
    if current_user.toggl_token.nil?
      redirect_to :back, alert: "No Toggl API key was found for user"
    else
      begin
        Issue.find(params[:id]).start_timer(current_user.toggl_token, summary)
        @toggl_result = true
      rescue => e
        @toggl_result = false
      end
    end
  end

  def load_comments
    @ticket_number = params[:ticket_number]
    begin
      @comments = Issue.get_comments(@ticket_number)
    rescue JIRA::HTTPError => e
      @comments = nil
    end
  end

  def post_comment
    ticket_number = params[:ticket_number]
    comment = params[:comment]
    begin
      Issue.post_comment(current_user, ticket_number, comment)
    rescue JIRA::HTTPError => e
      flash[:comment_post_alert] = "An Error Occurred While Trying To Post The Comment To Jira"
    end
    redirect_to load_comments_url(ticket_number: ticket_number)
  end

end
