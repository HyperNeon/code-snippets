require 'rails_helper'

RSpec.describe Issue, :type => :model do
  let(:investigation) { create(:investigation) }
  let(:util) { create(:utility) }
  let!(:issue) { create(:issue, investigation_id: investigation.id, utility_id: util.id) }
  let(:user) { create(:user) }
  let(:tickets) {[
    {
      "key" => "PO-17",
      "fields" => {
        "status" => {
          "name" => "closed",
          "statusCategory" => {
            "name" => "In Progress"
          }
        },
        "customfield_10051" => [
          {
            "value" => issue.utility.code
          }
        ],
        "assignee" => {
          "name" => "Steve Rogers"
        },
        "created" => "2015-02-28 00:59:35",
        "updated" => "2015-02-28 01:00:01",
        "description" => "Captain America was here"
      }
    },
    {
      "key" => "PO-18",
      "fields" => {
        "status" => {
          "name" => "in progress",
          "statusCategory" => {
            "name" => "In Progress"
          }
        },
        "customfield_10051" => [
          {
            "value" => "TEST1" 
          }
        ]
      }
    }      
  ]}
  
  describe ".create_issues" do
    subject(:create_issues) { Issue.create_issues(investigation.id, tickets) }
    
    it "creates a new utility if it's not found" do
      create_issues
      expect(Utility.where(code: "TEST1")).to exist
    end
    
    it "creates a new issue for new tickets" do
      create_issues
      expect(Issue.where(investigation_id: investigation.id, ticket_number: "PO-18")).to exist
    end

    it "sets marks issue as read if ticket is not in new status" do
      create_issues
      expect(Issue.new_issues.count).to eq(0)
    end
  end
  
  describe "#run_query" do

    it "calls ITQuery.get_query_response with all params" do
      method = :method
      query = {query: "do stuff"}
      options = {option: "option_1"}
      uuid = 1234

      exp_options = options.merge!({client: issue.utility.code, uuid: uuid})

      ITQuery.expects(:get_query_response).with(method, query, exp_options)
      issue.run_query(method: method, query: query, options: options, uuid: uuid)
    end
  end
  
  describe "#get_issue_data" do
    
    it "returns a formatted hash of issue data" do
      JiraAPIConnection.stubs(:query).returns(tickets)
      expected_response = {
        "Issue ID" => issue.id
      }.merge!(Issue.format_ticket_data(tickets[0]))

      expect(issue.get_issue_data).to eq(expected_response)
    end
  end
  
  describe ".get_ticket_data" do
    
    it "returns a formatted hash of ticket data" do
      JiraAPIConnection.stubs(:query).returns(tickets)
      expected_response = {
        "Issue ID" => "None"
      }.merge!(Issue.format_ticket_data(tickets[0]))

      expect(Issue.get_ticket_data("po-17")).to eq(expected_response)
    end
  end
  
  describe "#mark_as_viewed" do
    
    it "sets investigation path status to 1" do
      issue.mark_as_viewed
      expect(issue.investigation_path_status).to eq(1)
    end
  end

  describe '.assign' do

    it 'calls JiraAPIConnection.assign with passed params' do
      ticket_number = 'PO-17'
      assignee = 'Goku'
      comment = 'Its over 9000!'
      JiraAPIConnection.expects(:assign_ticket).with(ticket_number, user, assignee, comment)
      Issue.assign(ticket_number, user, assignee, comment)
    end
  end

  describe '#get_transitions' do

    it 'calls JiraAPIConnection.get_transitions with user' do
      JiraAPIConnection.expects(:get_transitions).with(issue.ticket_number, user)
      issue.get_transitions(user)
    end
  end

  describe '.get_ticket_transitions' do

    it 'calls JiraAPIConnection.get_transitions with passed params' do
      ticket_number = 'PO-17'
      JiraAPIConnection.expects(:get_transitions).with(ticket_number, user)
      Issue.get_ticket_transitions(user, ticket_number)
    end
  end

  describe '.update_status' do

    it 'calls JiraAPIConnection.update_status with passed params' do
      ticket_number = 'PO-17'
      status_id = 1
      resolution = 'Fixed'
      comment = 'We fixed it'
      JiraAPIConnection.expects(:set_transition).with(ticket_number, user, status_id, resolution, comment)
      Issue.update_status(ticket_number, user, status_id, resolution, comment)
    end
  end

  describe '.post_comment' do

    it 'calls JiraAPIConnection.comment_on_ticket with passed params' do
      ticket_number = 'PO-17'
      comment = 'Heres a comment'
      JiraAPIConnection.expects(:comment_on_ticket).with(ticket_number, user, comment)
      Issue.post_comment(user, ticket_number, comment)
    end
  end

  describe '#post_comment' do

    it 'calls Issue.post_comment with passed params' do
      comment = 'comment'
      Issue.expects(:post_comment).with(user, issue.ticket_number, comment)
      issue.post_comment(user, comment)
    end
  end

  describe '#start_timer' do

    it 'calls TogglAPIConnection.start_time with formatted summary' do
      token = 1
      summary = 'Ticket Summary'
      expected_description = "#{issue.ticket_number.upcase} #{summary}"
      TogglAPIConnection.expects(:start_time).with(token, expected_description, tags = [issue.investigation.name])
      issue.start_timer(token, summary)
    end
  end

  describe '.get_comments' do

    it 'calls JiraAPIConnection.get_comments with ticket_number' do
      ticket_number = 'PO-17'
      JiraAPIConnection.expects(:get_comments).with(ticket_number)
      Issue.get_comments(ticket_number)
    end
  end

  describe '.get_multiple_ticket_data' do


    it 'returns an empty array if no issues are passed in' do
      expect(Issue.get_multiple_ticket_data([])).to eq([])
    end

    it 'calls JiraAPIConnection.query with the correct query' do
      expected_query = "issue in (#{issue.ticket_number})"
      JiraAPIConnection.expects(:query).with(expected_query).returns([])
      Issue.get_multiple_ticket_data(Issue.all)
    end

    it 'returns a formatted array of ticket data if issues are submitted' do
      expected_response = [
        Issue.format_ticket_data(tickets[0])
      ]
      JiraAPIConnection.stubs(:query).returns([tickets[0]])
      expect(Issue.get_multiple_ticket_data(Issue.all)).to eq(expected_response)
    end

    it 'returns nil if JIRA::HTTPError raised' do
      JiraAPIConnection.stubs(:query).raises(JIRA::HTTPError.new('error'))
      expect(Issue.get_multiple_ticket_data(Issue.all)).to be_nil
    end
  end

  describe '.format_ticket_data' do

    it 'returns a properly formatted hash of ticket data' do
      expected_response = {
        "Ticket Number" => tickets[0]["key"],
        "Utility" => "#{issue.utility.code} ",
        "Summary" => tickets[0]["fields"]["summary"],
        "Status" => tickets[0]["fields"]["status"]["name"],
        "Assignee" => tickets[0]["fields"]["assignee"] ? tickets[0]["fields"]["assignee"]["name"] : "Unassigned",
        "Created" => Time.parse(tickets[0]["fields"]["created"]),
        "Updated" => Time.parse(tickets[0]["fields"]["updated"]),
        "Description" => tickets[0]["fields"]["description"],
        status_color: 'yellow',
        flagged: true
      }

      expect(Issue.format_ticket_data(tickets[0])).to eq(expected_response)
    end
  end
end
