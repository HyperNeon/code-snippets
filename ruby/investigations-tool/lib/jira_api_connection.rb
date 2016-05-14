module JiraAPIConnection

  module_function
  
  def query(query)
    jira_client = JIRA::Client.new(JIRARuby::JIRA_OPTIONS)
    results = jira_client.Issue.jql(query, {:max_results => 100000})
      
    # {:max_results => 200}
    jql_results = []
    results.each do |result|
      jql_results.push result.attrs
    end
    
    jql_results
  end

  def greenhopper_query(query)
    jira_client = JIRA::Client.new(JIRARuby::JIRA_OPTIONS)

    results = jira_client.get('/rest/greenhopper/latest/' + query)
    JSON.parse(results.body)
  end

  def get_comments(ticket_number)
    client = JIRA::Client.new(JIRARuby::JIRA_OPTIONS)
    ticket = client.Issue.find(ticket_number, expand: "renderedFields")
    ticket.renderedFields["comment"]["comments"]
  end

  def search_users(username)
    jira_client = JIRA::Client.new(JIRARuby::JIRA_OPTIONS)
    response = jira_client.get('/rest/api/latest/user/search?username=' + URI.encode(username))
    results = JSON.parse(response.body)
    results.map { |r| {display_name: r["displayName"], name: r["name"]} }
  end

  def assign_ticket(ticket_number, user, assignee, comment = '')
    if comment.blank?
      comment_params = {}
    else
      comment_params = {
        "update" => {
          "comment" => [
            {
              "add" => {
                "body" => comment
              }
            }
          ]
        }
      }
    end
    update_params = {
        "fields" => {
            "assignee" => {
                "name" => assignee
            }
        }
    }
    update_params.merge!(comment_params)

    update_ticket(ticket_number, user, update_params)
  end

  def comment_on_ticket(ticket_number, user, comment)
    update_params = {
        "update" => {
            "comment" => [
              {
                  "add" => {
                      "body" => comment
                  }
              }
            ]
        }
    }
    update_ticket(ticket_number, user, update_params)
  end

  def update_ticket(ticket_number, user, update_params)
    client = JIRARuby.client_for_user!(user)
    ticket = client.Issue.find(ticket_number)
    ticket.save(update_params)
  end

  def get_transitions(ticket_number, user)
    client = JIRARuby.client_for_user!(user)
    ticket = client.Issue.find(ticket_number)
    transitions = client.Transition.all(:issue => ticket)
    transitions.map { |t| {name: t.name, id: t.id, type: t.to.statusCategory["name"]} }
  end

  def set_transition(ticket_number, user, transition_id, resolution = nil, comment = '')
    client = JIRARuby.client_for_user!(user)
    ticket = client.Issue.find(ticket_number)
    transition = ticket.transitions.build
    fields = resolution.present? ? {"resolution" => {"name" => resolution}} : {}
    if comment.blank?
      update_params = {}
    else
      update_params = {
        "comment" => [
          {
            "add" => {
              "body" => comment
            }
          }
        ]
      }
    end

    transition.save!("transition" => {"id" => transition_id}, "fields" => fields, "update" => update_params)
  end

end