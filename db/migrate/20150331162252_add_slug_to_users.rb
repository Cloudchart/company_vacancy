class AddSlugToUsers < ActiveRecord::Migration
  def up
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
    User.where.not(twitter: nil).each { |user| user.update(slug: user.twitter) if user.twitter.present? }
  end

  def down
    remove_index :users, :slug
    remove_column :users, :slug
  end
end
