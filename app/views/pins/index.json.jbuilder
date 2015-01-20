@__relations          = {}
@__included_relations = (params[:relations] || '').split(',').map(&:to_sym)

def should_include?(name)
  @__included_relations.include?(:all) or @__included_relations.include?(name)
end

def ensure_relation(name)
  @__relations[name] ||= []
end


# Render pins
#
json.pins @pins do |pin|
  json.partial! 'pin', pin: pin
end


# Pinnables: Post
#
@pins.group_by(&:pinnable_type).each do |pinnable_type, pins|
  
  case pinnable_type
  when 'Post'
    next unless should_include?(:posts)
    
    pinnable_relations = {
      owner:        :owners,
      pictures:     nil,
      paragraphs:   nil,
      blocks:       nil
    }.select  { |name, map| should_include?(map || name) }
    
    pinnables = Post.includes(pinnable_relations.keys).find(pins.map(&:pinnable_id)).each do |pinnable|
      pinnable_relations.each do |name, map|
        ensure_relation(map || name) << pinnable.public_send(name)
      end
    end

    json.posts pinnables
  end
  
end


# Owners: Company
#

owners = ensure_relation(:owners).flatten.uniq

json.owners do
  owners.group_by(&:class).each do |owner_class, items|
    owner_name = owner_class.name.downcase
    json.set! owner_name.pluralize, items do |item|
      json.partial! owner_name, :"#{owner_name}" => item
    end
  end
end if should_include?(:owners) and owners.any?


# Blocks
#
blocks = ensure_relation(:blocks).flatten.uniq
json.blocks blocks if should_include?(:blocks) and blocks.any?


# Block identities
#
block_identities = should_include?(:block_identities) ? BlockIdentity.where(block_id: blocks.map(&:uuid)).flatten.uniq : []
json.block_identities block_identities if block_identities.any?


# Pictures
#
pictures = ensure_relation(:pictures).flatten.uniq

json.pictures pictures do |picture|
  json.partial! 'picture', picture: picture
end if should_include?(:pictures) and pictures.any?


# Paragraphs
#
paragraphs = ensure_relation(:paragraphs).flatten.uniq

json.paragraphs paragraphs do |paragraph|
  json.partial! 'paragraph', paragraph: paragraph
end if should_include?(:paragraphs) and paragraphs.any?


# Identities: People, Vacancies
#

json.identities do
  block_identities.group_by { |item| item.identity_type }.each do |identity_type, items|
    identities    = identity_type.constantize.find(items.map(&:identity_id))
    identity_name = identity_type.downcase
    json.set! identity_name.pluralize, identities do |identity|
      json.partial! identity_name, :"#{identity_name}" => identity
    end
  end
end if should_include?(:identities)
