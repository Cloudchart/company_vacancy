module PinboardsHelper
  
  
  def load_pinnable_posts(ids, deep = false)
    result    = {}
    includes  = deep ? [:owner, :pictures, :paragraphs, blocks: { block_identities: :identity }, taggings: :tag] : [:owner]
    
    posts = Post.includes(includes).find(ids).each do |post|
      (result[post.owner.class.name.downcase.pluralize.to_sym] ||= []) << post.owner
      
      if post.blocks.loaded?
        block_identities  = post.blocks.map(&:block_identities).flatten
        identities        = block_identities.map(&:identity)
        
        (result[:blocks]            ||= []).concat(post.blocks)
        (result[:block_identities]  ||= []).concat(block_identities)

        identities.each do |identity|
          (result[identity.class.name.downcase.pluralize.to_sym] ||= []) << identity
        end
      end
      
      if post.taggings.loaded?
        (result[:taggings] ||= []).concat(post.taggings)
        
        post.taggings.each do |tagging|
          (result[:tags] ||= []) << tagging.tag
        end
      end
      
      (result[:pictures]    ||= []).concat(post.pictures)   if post.pictures.loaded?
      (result[:paragraphs]  ||= []).concat(post.paragraphs) if post.paragraphs.loaded?
    end
    
    result[:posts] = posts
    
    result
  end
  
  
end