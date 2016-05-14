require 'rails_helper'

RSpec.describe UtilityController, :type => :controller do

  let(:util) { create(:utility) }
  before do
    Utility.any_instance.stubs(:get_utility_data)
    sign_in :user, create(:user)
  end
  
  describe "GET index" do
    it "returns http success when no error is raised" do
      get :index, utility_id: util.id
      expect(response).to have_http_status(:success)
    end
    
    it "returns http success when JIRA::HTTPError is raised" do
      Utility.any_instance.stubs(:get_utility_data).raises(JIRA::HTTPError.new("FAILED"))
      get :index, utility_id: util.id
      expect(response).to have_http_status(:success)
    end
  end
end
