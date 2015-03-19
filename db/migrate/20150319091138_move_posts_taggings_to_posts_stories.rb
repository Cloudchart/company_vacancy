class MovePostsTaggingsToPostsStories < ActiveRecord::Migration
  def up
    Tagging.includes(:tag).where(taggable_type: 'Post').each do |tagging|
      story = Story.find_or_create_by!(name: tagging.tag.name, company: tagging.taggable.company)
      story.posts_stories.find_or_create_by!(post: tagging.taggable)
      tagging.destroy
      say "#{story.name} story processed"
    end
  end

  def down
    say 'Nothing to be done'
  end
end
