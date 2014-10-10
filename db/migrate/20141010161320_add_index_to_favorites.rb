class AddIndexToFavorites < ActiveRecord::Migration
  def change
    add_index :favorites, [:user_id, :favoritable_id, :favoritable_type], name: :favorites_idx, unique: true
  end
end
