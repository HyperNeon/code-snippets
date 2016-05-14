require 'jira'

module JiraService
  CONFIG = ConfigLoadingService.get_jira_credentials
  USERNAME = CONFIG['username']
  PASSWORD = CONFIG['password']
  JIRA_OPTIONS = {username: USERNAME, password: PASSWORD, site: 'https:///REDACTED/', auth_type: :basic, context_path: ''}

  JIRA_CLIENT = JIRA::Client.new(JIRA_OPTIONS)

  # This Method interacts with jira to publish tickets
  #
  # @param payload [Hash] Final payload we pass as a payload to jira api
  # Structure:
  #   @input:
  #         {
  #             "fields"=>{
  #                 "project"=>{
  #                     "key"=>"PO"
  #                 },
  #                 "summary"=>"pHER 2.0 - AMP - 2016-05-02",
  #                 "issuetype"=>{
  #                     "name"=>"New Pipeline Monitoring"
  #                 },
  #                 "priority"=>{
  #                     "id"=>"3"
  #                 },
  #                 "duedate"=>"2016-05-03",
  #                 "description"=>"This ticket tracks HER 2.0 generation"
  #             },
  #             :pd_meta_data=>{
  #                 :utility_code=>"AMP",
  #                 :product=>"her"
  #               }
  #         }
  #  "fields" key, is require by jira to create a ticket and populate the respective fields.
  #  "pd_meta_data" is not required by jira, but is used in the blocker linking service to filter out
  #  respective blockers and link them to the the ticket
  # @return issue [JIRA::Resource::IssueFactory]
  def self.create_ticket(payload)
    issue = JiraService::JIRA_CLIENT.Issue.build
    issue.save(payload)
    Rails.logger.info issue.attrs
    issue
  end

  def self.run_jql_query(query)
    JIRA_CLIENT.Issue.jql(query)
  end

  # Link the outward ticket to the inward ticket as blocker type
  # Example Gen Ticket - depends on - Blocker Ticket = inward - Dependent - outward
  def self.link_tickets(inward, outward, type)
    link = JIRA_CLIENT.Issuelink.build
    link.save({'type'=>{'name'=>type},'inwardIssue'=>{'key'=>inward.key},'outwardIssue'=>{'key'=>outward.key}})
  end
end
