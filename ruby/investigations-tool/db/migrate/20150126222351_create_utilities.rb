class CreateUtilities < ActiveRecord::Migration
  def change
    create_table :utilities do |t|
      t.string :code, null: false

      t.timestamps null: false
    end
  end
end
