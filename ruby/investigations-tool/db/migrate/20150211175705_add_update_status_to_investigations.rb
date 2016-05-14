class AddUpdateStatusToInvestigations < ActiveRecord::Migration
  def change
      add_column :investigations, :update_status, :boolean, null: false, default: false
  end
end
