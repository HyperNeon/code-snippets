class Issue < ActiveRecord::Base
  belongs_to :investigation
  belongs_to :utility
  validates_presence_of :investigation_id, :ticket_number, :utility_id
  scope :open_issues, -> { where('investigation_path_status != ? OR investigation_path_status IS ?', 0, nil) }
  scope :closed_issues, -> { where(investigation_path_status: 0) }
  scope :new_issues, -> { where(investigation_path_status: nil) }

  #TODO Allow issues to have multiple utilities
  def self.create_issues(investigation_id, tickets)
    tickets.each do |ticket|
      # Let's create utilities even if they're not already defined instead of simply ignoring them
      utility = Utility.find_or_create_by(code: ticket['fields']['customfield_10051'].first['value'].downcase)
      issue = Issue.find_or_create_by(investigation_id:investigation_id, ticket_number: ticket['key'], utility_id: utility.id)
      # Issues that have anything besides a new type status should be automatically marked as viewed
      issue.mark_as_viewed if ticket['fields']['status']['statusCategory']['name'] != 'New'
    end  
  end

  def run_query(method: nil, query: nil, options: {}, uuid: nil)
      options.merge!({client: self.utility.code, uuid: uuid})
      ITQuery.get_query_response(method, query, options)
  end

  def get_issue_data    
    ticket_query = "issue = #{self.ticket_number}"
    t = JiraAPIConnection.query(ticket_query).first

    {
      "Issue ID" => self.id
    }.merge!(Issue.format_ticket_data(t))

  end
  
  def self.get_ticket_data(ticket_number)
    ticket_query = "issue = #{ticket_number}"
    t = JiraAPIConnection.query(ticket_query).first
    
    {
      "Issue ID" => 'None'
    }.merge!(Issue.format_ticket_data(t))

  end

  def mark_as_viewed
    update_attributes(investigation_path_status: 1)
  end

  def self.assign(ticket_number, user, assignee, comment)
    JiraAPIConnection.assign_ticket(ticket_number, user, assignee, comment)
  end

  def get_transitions(user)
    JiraAPIConnection.get_transitions(self.ticket_number, user)
  end

  def self.get_ticket_transitions(user, ticket_number)
    JiraAPIConnection.get_transitions(ticket_number, user)
  end

  def self.update_status(ticket_number, user, status_id, resolution, comment)
    JiraAPIConnection.set_transition(ticket_number, user, status_id, resolution, comment)
  end

  def self.post_comment(user, ticket_number, comment)
    JiraAPIConnection.comment_on_ticket(ticket_number, user, comment)
  end

  def post_comment(user, comment)
    Issue.post_comment(user, self.ticket_number, comment)
  end

  def start_timer(token, summary)
    description = "#{self.ticket_number.upcase} #{summary}"
    TogglAPIConnection.start_time(token, description, tags = [self.investigation.name])
  end

  def self.get_comments(ticket_number)
    JiraAPIConnection.get_comments(ticket_number)
  end

  def self.get_multiple_ticket_data(issues)
    if issues.any?
      ticket_list = issues.pluck(:ticket_number)
      begin
        ticket_query = "issue in (#{ticket_list.join(',')})"
        tickets = JiraAPIConnection.query(ticket_query)

        tickets.map { |ticket| Issue.format_ticket_data(ticket) }

          # Jira will throw an error when searching for specific tickets if that ticket has been deleted
      rescue JIRA::HTTPError => e
        # If we receive this error then that means one of the open tickets has been deleted.
        return nil
      end
    else
      []
    end

  end

  def self.format_ticket_data(t)
    {
      "Ticket Number" => t["key"],
      "Utility" => Issue.get_utility_clients(t),
      "Summary" => t["fields"]["summary"],
      "Status" => t["fields"]["status"]["name"],
      "Assignee" => t["fields"]["assignee"] ? t["fields"]["assignee"]["name"] : "Unassigned",
      "Created" => Time.parse(t["fields"]["created"]),
      "Updated" => Time.parse(t["fields"]["updated"]),
      "Description" => t["fields"]["description"],
      status_color: Issue.status_color(t),
      flagged: Issue.flagged_ticket?(t)
    }
  end

  def self.flagged_ticket?(ticket)
    if ticket['fields']['status']['statusCategory']['name'] == 'New'
      #This is a new item, we should flag after 5 days
      Time.now-5.days > Time.parse(ticket["fields"]["created"])
    elsif ticket['fields']['status']['statusCategory']['name'] != 'Complete'
      #This is an in progress ticket, we should flag after 30 days
      Time.now-30.days > Time.parse(ticket["fields"]["created"])
    else
      #Completed ticket, do not flag
      false
    end
  end

  def self.status_color(ticket)
    case ticket['fields']['status']['statusCategory']['name']
    when 'New'
      'red'
    when 'Complete'
      'rgb(0,218,0)'
    else
      'yellow'
    end
  end

  def self.get_utility_clients(t)
    if t['fields']['customfield_10051'].nil?
      utilities = 'None'
    else
      utilities = t['fields']['customfield_10051'].inject("") {|u, code| u + code["value"] + " "}
    end
    utilities
  end
end
