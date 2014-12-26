class RemovePostTaggings < ActiveRecord::Migration
  def up
    say 'Removing post taggings...'
    Tagging.where(taggable_type: 'Post').delete_all
  end

  def down
    say 'Nothing to be done'
  end
end
