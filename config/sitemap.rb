# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = root_url
# SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  # Pinboards
  #
  add collections_path, changefreq: 'daily'

  Pinboard.available.find_each do |pinboard|
    add collection_path(pinboard), lastmod: pinboard.updated_at, changefreq: 'daily'
  end

  # Pins
  #
  Pin.insights.find_each do |pin|
    add insight_path(pin), lastmod: pin.updated_at, changefreq: 'monthly'
  end

  # Users
  #
  User.where.not(twitter: nil).find_each do |user|
    add user_path(user), lastmod: user.updated_at, changefreq: 'daily'
  end

  # Companies
  #
  Company.published.find_each do |company|
    add company_path(company), lastmod: company.updated_at

    # Posts
    #
    company.posts.only_public.find_each do |post|
      add post_path(post), lastmod: post.updated_at
    end
  end

  # Pages
  #
  Page.find_each do |page|
    add page_path(page), lastmod: page.updated_at
  end

end
