require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  # Defining anonymous controller method to test application wide behavior / authentication
  controller do
    def index
      redirect_to :root
    end

    def authorize_test
      authorize_jira
      redirect_to :root
    end
  end

  describe "GET root" do
    it "returns http success when user is signed in" do
      sign_in :user, create(:user)
      get :index
      expect(response).to redirect_to(:root)
    end

    it "redirects to sign_in page when user is not signed in" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end
  end

  describe ".authorize_jira" do
    let(:user) { create(:user, first_name: "Random", last_name: "Person") }
    before do
      sign_in user
      routes.draw { get "authorize_test" => "anonymous#authorize_test" }
    end

    it "expects client_for_user! to be called" do
      JIRARuby.expects(:client_for_user!).with(user)
      get :authorize_test
    end

    it "redirects to new_jira_session_url if Access token isn't defined" do

      JIRARuby.stubs(:client_for_user!).raises(JIRA::OauthClient::UninitializedAccessTokenError.new("Error"))
      get :authorize_test
      expect(response).to redirect_to(new_jira_session_url)
    end
  end

  describe "GET search_jira_users" do
    before do
      sign_in :user, create(:user)
      routes.draw { get 'search_jira_users' => 'anonymous#search_jira_users' }
    end

    let(:user) { "Pikachu" }
    subject(:search) { get :search_jira_users, username: user }

    it "calls search_users with username" do
      JiraAPIConnection.expects(:search_users).with(user)
      search
    end

    it "returns successfully if an error occurs while searching" do
      JiraAPIConnection.stubs(:search_users).raises{StandardError.new("Pikachu Escaped")}
      search
      expect(response).to have_http_status(:success)
    end
  end
end