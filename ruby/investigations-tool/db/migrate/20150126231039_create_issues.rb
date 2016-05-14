class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.belongs_to :investigation, index: true, null: false
      t.string :ticket_number, null: false
      t.belongs_to :utility, index: true, null: false
      t.integer :investigation_path_status

      t.timestamps null: false
    end
  end
end
