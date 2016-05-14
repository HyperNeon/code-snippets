require 'spec_helper'
require 'ostruct'

describe JiraSessionsController do
  let(:user) { create(:user, first_name: "RANDOM", last_name: "PERSON") }
  let(:token) { 'fake_token' }
  let(:secret) { 'fake_secret' }
  let(:authorize_url) { 'https:///REDACTED//plugins/servlet/oauth/authorize?oauth_token=fake_token'}
  before do
    sign_in user
    controller.class.skip_before_filter :authorize_jira
  end

  describe "GET 'new'" do
    subject(:get_new) { get :new }
    before do
      # Setting up client request call
      client = mock('client')
      JIRARuby.stubs(:client).returns(client)
      request_token = {:token => token, :secret => secret, :authorize_url => authorize_url}
      client.stubs(:request_token).returns(OpenStruct.new(request_token))
      get_new
    end

    it "assigns session[:request_token]" do
      expect(session[:request_token]).to eq "fake_token"
    end

    it "assigns session[:request_secret]" do
      expect(session[:request_secret]).to eq "fake_secret"
    end

    it "redirects to authorize_url" do
      expect( response ).to redirect_to(authorize_url)
    end
  end

  describe "GET 'authorize'" do
    let(:client) { mock('client') }
    before do
      JIRARuby.stubs(:client).returns(client)
    end

    subject(:authorize) do
      get :authorize, nil, {request_token: token, request_secret: secret, return_to: "confirmation/show_blocker"}
    end

    it "expects set_request_token client method to be called" do
      client.stubs(:init_access_token).returns(OpenStruct.new({:token => nil, :secret => nil}))
      client.expects(:set_request_token).with(token, secret)
      authorize
    end

    it "expects set_request_token client method to be called" do
      client.stubs(:set_request_token)
      client.expects(:init_access_token).with(:oauth_verifier => "fake_oauth_verifier").returns(
        OpenStruct.new({:token => nil, :secret => nil})
      )
      get :authorize, {oauth_verifier: "fake_oauth_verifier"}, {return_to: "confirmation/show_blocker"}
    end

    context "saves access token to current_user" do
      before do
        client.stubs(:set_request_token)
        client.stubs(:init_access_token).returns(OpenStruct.new({:token => token, :secret => secret}))
      end

      it "sets access token" do
        authorize
        user.reload
        expect(user.jira_access_token).to eq token
      end

      it "sets secret access key" do
        authorize
        user.reload
        expect(user.jira_access_key).to eq secret
      end

      it "deletes request_token from session" do
        authorize
        expect(session[:request_token]).to be_nil
      end

      it "deletes request_secret from session" do
        authorize
        expect(session[:request_secret]).to be_nil
      end

      it "redirects to correct path" do
        authorize
        expect(response).to redirect_to("confirmation/show_blocker")
      end
    end
  end
end
