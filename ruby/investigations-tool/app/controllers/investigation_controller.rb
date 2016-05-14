class InvestigationController < ApplicationController
  respond_to :html, :js
  
  def index
    @investigation = Investigation.find(params[:id])
    begin
      @investigation_data = @investigation.get_investigation_data
    rescue JIRA::HTTPError => e
      # A deleted ticket was found while trying to load the page. Should get taken care of on the next refresh
      @investigation_data = ['ticket_deleted']
    rescue SocketError => e
      @investigation_data = ['jira_down']
    end
  end
  
  def refresh
    @investigation = Investigation.find(params[:id])
    unless @investigation.update_status
      @investigation.update_attributes(update_status: true)
      Thread.new {@investigation.update}
    end
    redirect_to investigation_url(id: @investigation.id)
  end
end
