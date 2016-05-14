class CreateInvestigations < ActiveRecord::Migration
  def change
    create_table :investigations do |t|
      t.string :name, null: false
      t.text :jira_search_query, null: false
      t.text :investigation_path

      t.timestamps null: false
    end
  end
end
