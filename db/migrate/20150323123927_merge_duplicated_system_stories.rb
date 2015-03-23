class MergeDuplicatedSystemStories < ActiveRecord::Migration
  def up
    %w(growth funding traction leadership product).each do |system_story_name|
      system_story = Story.find_by(name: system_story_name, company: nil)
      next unless system_story
      say "Processing #{system_story_name}..."

      Story.includes(:posts_stories).where(name: system_story_name).where.not(company: nil).each do |story|
        story.posts_stories.each do |posts_story|
          system_story.posts_stories.create(post: posts_story.post)
          say 'posts_story created', true
        end
        story.destroy
        say "#{story.name} destroyed", true
      end
    end
  end

  def down
    say 'Nothing to be done'
  end
end
