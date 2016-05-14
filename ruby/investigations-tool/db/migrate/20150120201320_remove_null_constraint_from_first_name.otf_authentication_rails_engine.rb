# This migration comes from otf_authentication_rails_engine (originally 20140116003514)
class RemoveNullConstraintFromFirstName < ActiveRecord::Migration
  def up
    change_column :users, :first_name, :string, null: true
  end

  def down
    change_column :users, :first_name, :string, null: false
  end
end
