class CreateActivitySessions < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :activity_type
      t.datetime :clock_in
      t.datetime :clock_out

      t.timestamps
    end
  end
end
