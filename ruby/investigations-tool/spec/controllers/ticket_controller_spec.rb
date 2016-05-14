require 'rails_helper'

RSpec.describe TicketController, :type => :controller do
  let(:issue) { create(:issue) }
  before do 
    Issue.stubs(:get_ticket_data)
    Issue.stubs(:get_available_queries)
    Issue.any_instance.stubs(:get_issue_data)
    Issue.stubs(:get_ticket_transitions)
    sign_in :user, create(:user, jira_access_token: 1, jira_access_key:1)
  end

  describe "GET index" do
    subject(:index) { get :index, ticket: issue.ticket_number }
    
    it "redirects to issue/index if 1 associated issue is found" do
      index
      expect(response).to redirect_to issue_url(id: issue.id)
    end
    
    it "returns http success if other than 1 associated issue is found" do
      create(:issue)
      index
      expect(response).to have_http_status(:success)
    end
    
    it "returns http success if JIRA::HTTPError is raised" do
      create(:issue)
      Issue.stubs(:get_ticket_data).raises(JIRA::HTTPError.new("FAILED"))
      index
      expect(response).to have_http_status(:success)
    end
  end
end
