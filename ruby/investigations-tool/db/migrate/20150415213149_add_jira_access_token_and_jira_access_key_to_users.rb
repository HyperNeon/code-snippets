class AddJiraAccessTokenAndJiraAccessKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :jira_access_token, :string
    add_column :users, :jira_access_key, :string
  end
end
