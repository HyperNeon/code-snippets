class UtilityController < ApplicationController
  def index
    @utility = Utility.find(params[:utility_id])
    begin
      @utility_data = @utility.get_utility_data
    rescue JIRA::HTTPError => e
      # A deleted ticket was found while trying to load the page. Should get taken care of on the next refresh
      @utility_data = nil
    end
  end
end
