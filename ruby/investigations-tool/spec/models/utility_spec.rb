require 'rails_helper'

RSpec.describe Utility, :type => :model do
  let(:util) { create(:utility) }

  describe ".refresh_utility_list" do
    
    it "creates 2 new utilities" do
      
      utility_codes = [util.code, "test1", "test2"]
      
      utilities = utility_codes.map do |code|
        fake_util = mock
        fake_util.stubs(:code).returns(code)
        fake_util
      end 
      UTILITY_CONFIG.stubs(:getUtilities).returns(utilities)
      
      Utility.refresh_utility_list
      expect(Utility.pluck(:code)).to eq(utility_codes)
    end
  end
  
  describe "#get_utility_data" do
    
    it "returns a formatted hash of all issue data organized by investigation type" do
      investigation1 = create(:investigation)
      investigation2 = create(:investigation, name: "Small Files")
      issue_new = create(:issue, investigation_id:investigation1.id, utility_id: util.id)
      issue_viewed = create(:issue, investigation_id:investigation2.id, utility_id: util.id,
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
        issue_viewed.investigation.name => [
          {
            "Issue ID" => issue_viewed.id
          }.merge!(Issue.format_ticket_data(tickets[1]).except("Description", :status_color))
        ]
      }
      
      expect(util.get_utility_data).to eq(expected_response) 
    end 
  end
end
