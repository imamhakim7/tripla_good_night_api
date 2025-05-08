class AddIndexesForOptimization < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # Indexes for activity_sessions table
    add_index :activity_sessions, [ :user_id, :activity_type ], name: 'index_activity_sessions_on_user_and_type', algorithm: :concurrently
    add_index :activity_sessions, [ :user_id, :clock_in, :clock_out ], name: 'index_activity_sessions_on_user_and_times', algorithm: :concurrently

    # Indexes for relationships table
    add_index :relationships, [ :user_id, :action_type ], name: 'index_relationships_on_user_and_action_type', algorithm: :concurrently
    add_index :relationships, [ :user_id, :relationable_type, :relationable_id ], name: 'index_relationships_on_user_and_relationable', algorithm: :concurrently

    # Index for users table
    add_index :users, :refresh_token, name: 'index_users_on_refresh_token', algorithm: :concurrently
  end
end
