class Utility < ActiveRecord::Base
  has_many :issues
  validates_presence_of :code
  
  def self.refresh_utility_list
    exclude_list = ['/REDACTED/']

    utilities = /REDACTED/.getUtilities(:tier => Settings./REDACTED/_tier)

    utilities.each {|u| Utility.find_or_create_by(code: u.code) unless exclude_list.include?(u.code)}
  end
  
  def get_utility_data
    utility_data = {}
    
    open_issue_list = self.issues.open_issues
    new_issue_list = self.issues.new_issues
    if open_issue_list.any?
      ticket_query = "issue in (#{open_issue_list.pluck(:ticket_number).join(',')})"
      tickets = JiraAPIConnection.query(ticket_query)
      open_issue_list -= new_issue_list
      
      utility_data = fill_utility_data(utility_data, new_issue_list, tickets, true)
      utility_data = fill_utility_data(utility_data, open_issue_list, tickets)  
    end
    
    utility_data
  end
  
  def fill_utility_data(investigation_data, issue_list, tickets, new_issues = false)

    issue_list.each do |issue|
      t = tickets.detect { |ticket| ticket["key"] == issue.ticket_number}
      ticket_data = {
        "Issue ID" => issue.id
      }.merge!(Issue.format_ticket_data(t).except("Description", :status_color))

      data_list_name = new_issues ? "New Issues" : issue.investigation.name
      if investigation_data[data_list_name]
        investigation_data[data_list_name] << ticket_data
      else
        investigation_data[data_list_name] = [ticket_data]
      end
    end
    
    investigation_data
  end
end
