class HistoryController < ApplicationController
  def index
    client_code = params[:client]
    investigation_name = params[:investigation]
    num_results = params[:num_results] ||= 300

    issues = Issue.all.reverse_order
    if client_code
      #Attempt to parse client
      util = Utility.find_by_code(client_code)
      if util
        issues = issues.where(utility_id: util.id)
      else
        flash[:alert] = "No Utility With Client Code: #{client_code}\n"
      end
    end

    if investigation_name
      #Attempt to parse investigation
      investigation = Investigation.find_by_name(investigation_name)
      if investigation
        issues = issues.where(investigation_id: investigation.id)
      else
        flash[:alert] = "No Investigation With Name: #{investigation_name}\n"
      end
    end

    # Let's be sure not to return too many items since this list can be HUGE if no
    # params are passed in
    issues = issues.limit(num_results)

    # Returns nil if an issue it encountered while querying JIRA
    ticket_data = Issue.get_multiple_ticket_data(issues)

    if ticket_data.nil?
      flash[:alert] = "There was a problem retrieving data for one of the tickets on this list.\n"\
        'This generally means that a deleted ticket has been found'
    else
      # Match tickets back up with issues
      @all_issue_data = issues.map do |issue|
        data_from_ticket = ticket_data.detect {|ticket| issue.ticket_number == ticket['Ticket Number']}
        {"Issue ID" => issue.id}.merge!(data_from_ticket.except("Description", :status_color))
      end
    end
  end
end

