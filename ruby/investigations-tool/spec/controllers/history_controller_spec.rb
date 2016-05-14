require 'rails_helper'

RSpec.describe HistoryController, :type => :controller do

  let(:investigation1) { create(:investigation) }
  let(:investigation2) { create(:investigation) }
  let(:utility1) { create(:utility, code: "demo") }
  let(:utility2) { create(:utility, code: "demo2") }
  let!(:issue1) { create(:issue, investigation_id: investigation1.id, utility_id: utility1.id) }
  let!(:issue2) { create(:issue, investigation_id: investigation2.id, utility_id: utility2.id) }
  let!(:issue3) { create(:issue, investigation_id: investigation2.id, utility_id: utility1.id) }

  before do
    tickets = [
      {
        'Ticket Number' => 'PO-17'
      },
      {
        'Ticket Number' => 'PO-18'
      }
    ]
    Issue.stubs(:get_multiple_ticket_data).returns(tickets)
    sign_in :user, create(:user)
  end

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns all issues given no params" do
      get :index
      expect(assigns(:all_issue_data).count).to eq(3)
    end


    it "returns limited records given num_results param" do
      get :index, num_results: 2
      expect(assigns(:all_issue_data).count).to eq(2)
    end

    it "returns only utility issues given client param" do
      get :index, client: utility2.code
      expected_response = [
        {
          'Issue ID' => issue2.id,
          'Ticket Number' => 'PO-17'
        }
      ]
      expect(assigns(:all_issue_data)).to eq(expected_response)
    end

    it "returns only investigation issues given investigation param" do
      get :index, investigation: investigation1.name
      expected_response = [
        {
          'Issue ID' => issue1.id,
          'Ticket Number' => 'PO-17'
        }
      ]
      expect(assigns(:all_issue_data)).to eq(expected_response)
    end

    it "returns only issues matching all params if given both investigation and client" do
      get :index, investigation: investigation2.name, client: utility1.code
      expected_response = [
        {
          'Issue ID' => issue3.id,
          'Ticket Number' => 'PO-17'
        }
      ]
      expect(assigns(:all_issue_data)).to eq(expected_response)
    end

  end

end
