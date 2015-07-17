class AddTargetToToken < ActiveRecord::Migration
  def up
    add_column  :tokens, :target_id,   :string, limit: 36
    add_column  :tokens, :target_type, :string

    add_index   :tokens, [:target_id, :target_type]
  end

  def down
    remove_index    :tokens, [:target_id, :target_type]

    remove_column   :tokens, :target_id,   :string
    remove_column   :tokens, :target_type, :string
  end
end
