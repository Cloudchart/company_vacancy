class ChangeColumnsInPosts < ActiveRecord::Migration
  def up
    add_column :posts, :effective_from, :date
    add_column :posts, :effective_till, :date
    add_column :posts, :position, :integer

    Company.includes(:posts).each do |company|
      say "Starting to update posts for #{company.name}" if company.posts.any?
      company.posts.order(:published_at).each_with_index do |post, index|
        post.update(
          effective_from: post.published_at.try(:to_date),
          effective_till: post.published_at.try(:to_date),
          position: index
        )
        say "#{post.id} post updated", true
      end
    end

    remove_column :posts, :published_at
    remove_column :posts, :is_published
  end

  def down
    add_column :posts, :is_published, :boolean, default: false
    add_column :posts, :published_at, :datetime

    Company.includes(:posts).each do |company|
      say "Starting to update posts for #{company.name}" if company.posts.any?
      company.posts.order(:published_at).each_with_index do |post, index|
        post.update(published_at: post.effective_from)
        say "#{post.id} post updated", true
      end
    end

    remove_column :posts, :effective_from
    remove_column :posts, :effective_till
    remove_column :posts, :position
  end
end
