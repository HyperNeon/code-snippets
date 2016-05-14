require 'rails_helper'

RSpec.describe Investigation, :type => :model do
  let(:investigation) { create(:investigation) }
  
  describe "#update" do
    subject(:update) { investigation.update }
    
    it "calls create_issues if tickets are returned" do
      JiraAPIConnection.stubs(:query).returns(["ticket"])
      Issue.expects(:create_issues)
      update
    end
    
    it "doesn't call create_issues if no tickets are returned" do
      JiraAPIConnection.stubs(:query).returns([])
      Issue.expects(:create_issues).never
      update
    end
    
    context "open issues" do
      let!(:issue) { create(:issue, investigation_id: investigation.id) }
      before do
        JiraAPIConnection.stubs(:query).with(investigation.jira_search_query).returns([])
      end
      
      it "calls process_tickets if only open issues exist" do
        ticket_query = "issue in (#{issue.ticket_number})"
        JiraAPIConnection.stubs(:query).with(ticket_query).returns([])
        investigation.expects(:process_tickets)
        update
      end
      
      it "calls process_with_deleted_tickets if a deleted ticket exists for an issue" do
        ticket_query = "issue in (#{issue.ticket_number})"
        JiraAPIConnection.stubs(:query).with(ticket_query).raises(JIRA::HTTPError.new("FAILED"))
        investigation.expects(:process_with_deleted_tickets)
        update
      end
    end
  end
  
  context "processing tickets" do
    let!(:issue1) {create(:issue, investigation_id: investigation.id)}
    let!(:issue2) {create(:issue, investigation_id: investigation.id)}
    let!(:issue3) {create(:issue, investigation_id: investigation.id, ticket_number: "PO-18")}
    let(:tickets) {[
      {
        "key" => "PO-17",
        "fields" => {
          "status" => {
            "name" => "closed",
            "statusCategory" => {
              "name" => "Complete"
            }
          }
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
          }
        }
      }      
    ]}
    
    describe "#process_tickets" do
      
      it "closes only issues associated with closed tickets" do
        investigation.process_tickets(tickets)
        statuses = investigation.issues.map(&:investigation_path_status)
        expect(statuses).to eq([0,0,nil])
      end
    end
    
    describe "#process_with_deleted_tickets" do
      
      it "closes issues associated with closed tickets and deletes issues with deleted tickets" do
        JiraAPIConnection.stubs(:query).with("issue = #{tickets[0]['key']}").returns([tickets[0]])
        JiraAPIConnection.stubs(:query).with("issue = #{tickets[1]['key']}").raises(JIRA::HTTPError.new("FAILED"))
        investigation.process_with_deleted_tickets(investigation.issues.pluck(:ticket_number))
        statuses = investigation.issues.map(&:investigation_path_status)
        expect(statuses).to eq([0,0])
      end
    end
  end
  
  describe "#get_investigation_data" do
    
    it "returns a formatted hash of all issue data organized by ticket status" do
      util = create(:utility)
      issue_new = create(:issue, investigation_id:investigation.id, utility_id: util.id)
      issue_viewed = create(:issue, investigation_id:investigation.id, utility_id: util.id,
        investigation_path_status: 1, ticket_number: "PO-18")
      tickets = [
        {
          "key" => issue_new.ticket_number,
          "fields" => {
            "summary" => "issue1",
            "status" => {
              "name" => "open",
              "statusCategory" => {
                "name" => "New"
              }
            },
            "customfield_10051" => [
              {
                "value" => issue_new.utility.code
              }
            ],
            "assignee" => {
              "name" => "Leeroy Jenkins"
            },
            "created" => "2015-02-28 00:59:35",
            "updated" => "2015-02-28 01:00:01"
          }
        },
        {
          "key" => issue_viewed.ticket_number,
          "fields" => {
            "summary" => "issue2",
            "status" => {
              "name" => "in progress",
              "statusCategory" => {
                "name" => "In Progress"
              }
            },
            "customfield_10051" => [
              {
                "value" => issue_viewed.utility.code
              }
            ],
            "assignee" => {
              "name" => "Peggy Carter"
            },
            "created" => "2015-02-28 00:59:35",
            "updated" => "2015-02-28 01:00:01"
          }
        }
      ]
      
      JiraAPIConnection.stubs(:query).returns(tickets)
      
      expected_response = {
        "New Issues" => [
          {
            "Issue ID" => issue_new.id
          }.merge!(Issue.format_ticket_data(tickets[0]).except("Description", :status_color))
        ],
        "in progress Issues" => [
          {
            "Issue ID" => issue_viewed.id
          }.merge!(Issue.format_ticket_data(tickets[1]).except("Description", :status_color))
        ]
      }
      
      expect(investigation.get_investigation_data).to eq(expected_response) 
    end 
  end
end
