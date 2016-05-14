require 'rails_helper'

RSpec.describe InvestigationController, :type => :controller do
  let(:investigation) { create(:investigation) }
  before do
    Investigation.any_instance.stubs(:get_investigation_data)
    sign_in :user, create(:user)
  end

  describe "GET index" do
    
    it "returns http success when no error is raised" do
      get :index, id: investigation.id
      expect(response).to have_http_status(:success)
    end
    
    it "returns http success when JIRA::HTTPError is raised" do
      Investigation.any_instance.stubs(:get_investigation_data).raises(JIRA::HTTPError.new("Failed"))
      get :index, id: investigation.id
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET refresh" do
    subject(:refresh) { get :refresh, id: investigation.id }
    
    it "redirects to index" do
      Investigation.any_instance.stubs(:update)
      refresh
      expect(response).to redirect_to(investigation_url(id:investigation.id))
    end
    
    context "update_status is false" do
      it "calls update" do
        Investigation.any_instance.expects(:update)
        refresh
        sleep 0.1
      end
      
      it "sets update_status to true" do
        Investigation.any_instance.stubs(:update)
        refresh
        investigation.reload
        expect(investigation.update_status).to be true
      end
    end
    
    context "update_status is true" do
      it" doesn't call update" do
        investigation.update_attributes(update_status: true)
        Investigation.any_instance.expects(:update).never
        refresh
      end
    end
  end
end
