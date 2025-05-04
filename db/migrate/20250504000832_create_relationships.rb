class CreateRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :relationships do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type
      t.references :relationable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
