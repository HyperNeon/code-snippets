require 'rails_helper'

RSpec.describe IssueController, :type => :controller do
  let(:util) { create(:utility) }
  let(:issue) { create(:issue, utility_id: util.id) }
  let(:user) { create(:user, jira_access_token:1, jira_access_key:1) }

  before do
    ITQuery.stubs(:get_available_queries)
    Issue.any_instance.stubs(:get_issue_data)
    Issue.any_instance.stubs(:get_transitions)
    sign_in user
  end

  describe "GET index" do
    subject(:index) { get :index, id: issue.id }
    
    it "returns http success when no error is raised" do
      index
      expect(response).to have_http_status(:success)
    end
  
    it "returns http success when JIRA::HTTPError is raised" do
      Issue.any_instance.stubs(:get_issue_data).raises(JIRA::HTTPError.new("Failed"))
      index
      expect(response).to have_http_status(:success)
    end

    it "redirects to jira session when jira key not found" do
      sign_in :user, create(:user, jira_access_token: 1)
      index
      expect(response).to redirect_to(new_jira_session_url)
    end

    it "redirects to jira session when jira token not found" do
      sign_in :user, create(:user, jira_access_key: 1)
      index
      expect(response).to redirect_to(new_jira_session_url)
    end
  end
  
  describe "POST show_query_details" do
    subject(:show_query_details) do
      xhr :post, :show_query_details, queries: [{name: "Q1"}, {name: "Q2"}].to_json,
      query_index: "Q2", id: issue.id
    end
        
    it "returns http success" do
      show_query_details
      expect(response).to have_http_status(:success)
    end
    
    it "returns the correct query from queries" do
      show_query_details
      expect(assigns(:query)).to eq({"name" => "Q2"})
    end
  end
  
  describe "POST run_query" do

    context "no options or query_id submitted" do
      let(:query_details) { { method: :submit_query_interface_query, name: "TEST", additional_info: {classname: "TEST_CLASS"}
        }.to_json }
        
      subject(:run_query) do
        xhr :post, :run_query, id: issue.id,
        query: query_details
      end
      
      it "returns http success" do
        Issue.any_instance.stubs(:run_query)
        run_query
        expect(response).to have_http_status(:success)
      end
      
      it "calls run query with correct params" do
        query_params = JSON.parse query_details
        Issue.any_instance.expects(:run_query).with(method: query_params['method'], query: query_params,
          options: {}, uuid: nil)
        run_query
      end
    end
    
    context "options submitted" do
      let(:query_details) { { method: :submit_query_interface_query, name: "TEST", additional_info: {classname: "TEST_CLASS"},
          options: ["test_option"]
        }.to_json }
        
      subject(:run_query) do
        xhr :post, :run_query, id: issue.id,
        query: query_details,
        "option-test_option".to_sym => "test option text"
      end
      
      it "call submit_query_interface_query with query and options" do
        query_params = [JSON.parse(query_details), {"test_option" => "test option text"}]
        Issue.any_instance.expects(:run_query).with(method: query_params[0]['method'], query: query_params[0],
          options: query_params[1], uuid: nil)
        run_query
      end
    end
    
    context "query id submitted" do
      
      it "calls submit_query_interface_query with query, options, uuid if options submitted" do
        
        query_details_with_options = {
          method: :submit_query_interface_query, name: "TEST",
          additional_info: {classname: "TEST_CLASS"}, options: ["test_option"]
        }.to_json
        
        query_params = [JSON.parse(query_details_with_options), {"test_option" => "test option text"}, '1234']      
        Issue.any_instance.expects(:run_query).with(method: query_params[0]['method'], query: query_params[0],
          options: query_params[1], uuid: query_params[2])
        
        xhr :post, :run_query, id: issue.id, query: query_details_with_options,
          "option-test_option".to_sym => "test option text", query_id: 1234
          
      end
      
      it "calls submit_query_interface_query with query, uuid if no options submitted" do
        
        query_details_no_options = {
          method: :submit_query_interface_query, name: "TEST", additional_info: {classname: "TEST_CLASS"}
        }.to_json
        
        query_params = [JSON.parse(query_details_no_options), {}, '1234']
        Issue.any_instance.expects(:run_query).with(method: query_params[0]['method'], query: query_params[0],
          options: query_params[1], uuid: query_params[2])
        
        xhr :post, :run_query, id: issue.id, query: query_details_no_options,
          "option-test_option".to_sym => "test option text", query_id: 1234
      end
    end 
  end
  
  describe "GET mark_as_viewed" do
    before { request.env['HTTP_REFERER'] = 'dashboard/index' }
    
    subject(:mark_as_viewed) { get :mark_as_viewed, id:issue.id }
    
    it "redirects to back" do
      mark_as_viewed
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end
    
    it "sets issue investigation_path_status to 1" do
      mark_as_viewed
      issue.reload
      expect(issue.investigation_path_status).to eq(1)
    end
  end

  describe "POST assign_ticket" do
    before { request.env['HTTP_REFERER'] = 'dashboard/index' }
    let(:assignee) { 'Leeroy Jenkins' }
    let(:ticket) { 'PO-17' }
    let(:comment) { 'Test' }
    subject(:assign) { post :assign_ticket, assignee: assignee, ticket: ticket, comment: comment }

    it "calls Issue.assign with passed in params" do
      Issue.expects(:assign).with(ticket, user, assignee, comment)
      assign
    end

    it "redirects to back if no error is raised" do
      Issue.stubs(:assign)
      assign
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end

    it "redirects to back if a JIRA::HTTPError is raised" do
      Issue.stubs(:assign).raises(JIRA::HTTPError.new("Broken"))
      assign
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end
  end

  describe "POST post_results_as_comment" do
    let(:issue) { create(:issue) }
    let(:table_json) {
      "[{\"key1\":\"key1\",\"key2\":\"key2\"},{\"key1\":\"value1\",\"key2\":\"value2\"}]"
    }
    let(:optional_comment) {"We Did It"}

    subject(:post_results) do
      xhr :post, :post_results_as_comment, id: issue.id, table_json: table_json,
        optional_comment: optional_comment
    end

    it "calls post_comment with a formated comment" do
      expected_output = optional_comment + "\n ---- \n"
      expected_output += "||key1||key2||\n|value1|value2|\n"
      expected_output += "This table was posted from *Investigations Tool* at [https:///REDACTED//issue/#{issue.id}/index]"

      Issue.any_instance.expects(:post_comment).with(user, expected_output)
      post_results
    end

    it "returns jira_post_result as true if there is no error" do
      Issue.any_instance.stubs(:post_comment)
      post_results
      expect(assigns(:jira_post_result)).to eq(true)
    end

    it "returns jira_post_result as false if there is a JIRA::HTTPError" do
      Issue.any_instance.stubs(:post_comment).raises(JIRA::HTTPError.new("Error"))
      post_results
      expect(assigns(:jira_post_result)).to eq(false)
    end
  end

  describe "POST update_status" do
    before { request.env['HTTP_REFERER'] = 'dashboard/index' }
    let(:status_id) { '1' }
    let(:ticket) { 'PO-17' }
    let(:resolution) { 'Fixed' }
    let(:comment) { 'Comment' }

    subject(:update_status) do
      post :update_status, status_id: status_id, ticket: ticket,
        resolution: resolution, comment: comment
    end

    it "calls update_status with all params" do
      Issue.expects(:update_status).with(ticket, user, status_id, resolution, comment)
      update_status
    end

    it "redirects to back if there is no error" do
      Issue.stubs(:update_status)
      update_status
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end

    it "redirects to back if a JIRA::HTTPError is raised" do
      Issue.stubs(:update_status).raises(JIRA::HTTPError.new("error"))
      update_status
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end
  end

  describe "POST start_timer" do
    before { request.env['HTTP_REFERER'] = 'dashboard/index' }
    let(:summary) { "This is the summary" }
    let(:issue) { create(:issue) }
    let(:toggl_token) { '1234' }

    subject(:start_timer) do
      xhr :post, :start_timer, id: issue.id, summary: summary
    end

    it "redirects to back if the user doesn't have a toggl token" do
      Issue.any_instance.stubs(:start_timer)
      start_timer
      expect(response).to redirect_to(request.env['HTTP_REFERER'])
    end

    context "User has a toggl token" do
      before { sign_in :user, create(:user, toggl_token: toggl_token) }

      it "calls start_timer" do
        Issue.any_instance.expects(:start_timer).with(toggl_token, summary)
        start_timer
      end

      it "sets toggl_result to true if no error received" do
        Issue.any_instance.stubs(:start_timer)
        start_timer
        expect(assigns(:toggl_result)).to eq(true)
      end

      it "sets toggl_result to false if any error is received" do
        Issue.any_instance.stubs(:start_timer).raises(StandardError.new('error'))
        start_timer
        expect(assigns(:toggl_result)).to eq(false)
      end
    end
  end

  describe "GET load_comments" do
    let(:ticket_number) { 'PO-17' }

    subject(:load_comments) do
      xhr :get, :load_comments, ticket_number: ticket_number
    end

    it "calls get_comments" do
      Issue.expects(:get_comments).with(ticket_number)
      load_comments
    end

    it "assigns ticket_number" do
      Issue.stubs(:get_comments)
      load_comments
      expect(assigns(:ticket_number)).to eq(ticket_number)
    end

    it "assigns comments if there are no errors" do
      comments = "Blah Blah"
      Issue.stubs(:get_comments).returns(comments)
      load_comments
      expect(assigns(:comments)).to eq(comments)
    end

    it "assigns comments as nil if there is a JIRA::HTTPError" do
      Issue.stubs(:get_comments).raises(JIRA::HTTPError.new("error"))
      load_comments
      expect(assigns(:comments)).to be_nil
    end
  end

  describe "POST post_comment" do
    before { Issue.stubs(:get_comments) }
    let(:ticket_number) { 'PO-17' }
    let(:comment) { 'Blah Blah' }

    subject(:post_comment) do
      post :post_comment, ticket_number: ticket_number, comment: comment
    end

    it "calls post_comment" do
      Issue.expects(:post_comment).with(user, ticket_number, comment)
      post_comment
    end

    it "redirects to load_comments if no error is raised" do
      Issue.stubs(:post_comment)
      post_comment
      expect(response).to redirect_to(load_comments_url(ticket_number: ticket_number))
    end

    it "redirects to load_comments if JIRA::HTTPError is raised" do
      Issue.stubs(:post_comment).raises(JIRA::HTTPError.new('error'))
      post_comment
      expect(response).to redirect_to(load_comments_url(ticket_number: ticket_number))
    end
  end
end
