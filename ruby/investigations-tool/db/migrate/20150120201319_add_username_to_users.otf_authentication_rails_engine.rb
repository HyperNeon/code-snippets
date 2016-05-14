# This migration comes from otf_authentication_rails_engine (originally 20140115235859)
class AddUsernameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :username, :string
    add_index :users, :username, unique: true

    change_column :users, :email, :string, null: true
  end

  def down
    remove_column :users, :username, :string
    change_column :users, :email, :string, null: false
  end
end
