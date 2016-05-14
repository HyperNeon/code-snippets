class BlockerLinkingService
  attr_accessor :blocker_list

  BLOCKER_QUERY = 'issue in linkedIssues(PO-17) and project != LOL AND summary !~ "CLIENTxCODE" AND summary !~ "PROD_INFO"'
  LINK_TYPE = 'Dependent'
  BLOCKER_REGEX_LIST = {her: /PRINT HOME_ENERGY/, eher: /EMAIL HOME_ENERGY/, hba: /PRE_BILL/, wami: /WEEKLY_AMI/,
    ebill: /E_BILL/}

  def initialize(blocker_tickets)
    #blockers
    @blocker_list = blocker_tickets
  end

  # Returns the subset of blockers to be associated with this client and product combo
  def filter_blockers(utility_code, product)
    @blocker_list.select do |issue|
      client_blocker_filter(issue, utility_code) && product_blocker_filter(issue, product)
    end
  end

  # Returns true if provided utility code matches one of the clients listed in issue or
  # if there are no clients or the /REDACTED/ client listed in the issue
  def client_blocker_filter(issue, utility_code)
    issue.customfield_10051.nil? || issue.customfield_10051.any? do |field|
      ticket_util = field['value'].downcase
      ticket_util == utility_code.downcase || ticket_util == '/REDACTED/'
    end
  end

  # Returns true if issue summary matches the provided products issue summary regex or if the product could not be determined
  def product_blocker_filter(issue, product)
    summary = issue.summary
    issue_product = BLOCKER_REGEX_LIST.detect {|_,regex| summary =~ regex }
    issue_product.nil? || product == issue_product.first
  end
end
