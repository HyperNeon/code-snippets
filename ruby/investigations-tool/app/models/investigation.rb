class Investigation < ActiveRecord::Base
  has_many :issues
  validates_presence_of :name, :jira_search_query
  validates_uniqueness_of :name
    
  def self.create_investigation(name, query)
    Investigation.create(name: name, jira_search_query: query)
  end

  def self.update_all_investigations
    Investigation.all.each do |investigation|
      begin
        investigation.update
      rescue SocketError => e
        Rails.logger info "#{e.message}"
      end
    end
  end
  
  # Uses the JQL query to get a list of active tickets and then creates new issues
  # then checks all open tickets to see if they've been closed
  def update
    begin
      self.update_attributes(update_status: true)

      tickets = JiraAPIConnection.query(self.jira_search_query)

      Issue.create_issues(self.id, tickets) unless tickets.empty?

      ticket_list = self.issues.open_issues.pluck(:ticket_number)
      if ticket_list.any?
        begin
          ticket_query = "issue in (#{ticket_list.join(',')})"
          tickets = JiraAPIConnection.query(ticket_query)
          process_tickets(tickets)
            # Jira will throw an error when searching for specific tickets if that ticket has been deleted
        rescue JIRA::HTTPError => e
          # If we receive this error then that means one of the open tickets has been deleted.
          # We need to loop through one by one to identify it
          process_with_deleted_tickets(ticket_list)
        end
      end
    ensure
      self.update_attributes(update_status: false)
    end
  end
  
  def self.clear_all_update_status
    Investigation.update_all(update_status:false)
  end
  
  # Loop through list of tickets and check for any in closed status
  def process_tickets(tickets)
    tickets.each do |ticket|
      if ticket["fields"]["status"]["statusCategory"]["name"].downcase == "complete"
        issues = Issue.where(ticket_number: ticket["key"])
        issues.update_all(investigation_path_status: 0)
      end
    end  
  end
  
  def process_with_deleted_tickets(ticket_list)
    # A deleted ticket was found, let's loop through each ticket and update individually
    ticket_list.each do |ticket_number|
      begin
        ticket_query = "issue = #{ticket_number}"
        tickets = JiraAPIConnection.query(ticket_query)
        process_tickets(tickets)
      rescue JIRA::HTTPError => e
        # Receiving this error means we've identified the deleted ticket
        # delete from our records
        Issue.where(ticket_number:ticket_number).delete_all
      end  
    end
  end
  
  def get_investigation_data
    investigation_data = {}
    
    open_issue_list = self.issues.open_issues
    new_issue_list = self.issues.new_issues
    if open_issue_list.any?
      ticket_query = "issue in (#{open_issue_list.pluck(:ticket_number).join(',')})"
      tickets = JiraAPIConnection.query(ticket_query)
      open_issue_list -= new_issue_list
      
      investigation_data = fill_investigation_data(investigation_data, new_issue_list, tickets, true)
      investigation_data = fill_investigation_data(investigation_data, open_issue_list, tickets)  
    end
    
    investigation_data
  end
  
  def fill_investigation_data(investigation_data, issue_list, tickets, new_issues = false)

    issue_list.each do |issue|
      t = tickets.detect { |ticket| ticket["key"] == issue.ticket_number}
      ticket_data = {
        "Issue ID" => issue.id
      }.merge!(Issue.format_ticket_data(t).except("Description", :status_color))

      data_list_name = new_issues ? "New Issues" : ticket_data["Status"] + " Issues"
      if investigation_data[data_list_name]
        investigation_data[data_list_name] << ticket_data
      else
        investigation_data[data_list_name] = [ticket_data]
      end
    end
    
    investigation_data
  end
  
end
