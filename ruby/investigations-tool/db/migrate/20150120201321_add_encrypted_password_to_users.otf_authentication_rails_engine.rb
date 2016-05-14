# This migration comes from otf_authentication_rails_engine (originally 20140605131620)
class AddEncryptedPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_password, :string
  end
end
