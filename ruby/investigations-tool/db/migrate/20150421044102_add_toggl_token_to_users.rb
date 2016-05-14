class AddTogglTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :toggl_token, :string
  end
end
