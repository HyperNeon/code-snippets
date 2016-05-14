FactoryGirl.define do
  factory :investigation do
    sequence(:name) { |n| "Test#{n}" }
    jira_search_query "JQL_query"
    investigation_path [1,2,3,4]
    update_status false
  end
end
