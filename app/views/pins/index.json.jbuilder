@__relations          = {}
@__included_relations = (params[:relations] || '').split(',').map(&:to_sym)

def should_include?(name)
  @__included_relations.include?(:all) or @__included_relations.include?(name)
end

def ensure_relation(name)
  @__relations[name] ||= []
end


ensure_relation(:pins).concat(@pins)


# Find pinnables
#
json.pinnables do
  @pins.group_by(&:pinnable_type).each do |pinnable_type, pins|
  
    case pinnable_type
    when 'Post'
    
      pinnable_relations = [:owner, :pictures, :paragraphs, blocks: { block_identities: :identity }]
    
      pinnables = Post.includes(pinnable_relations).find(pins.map(&:pinnable_id)).each do |pinnable|
        block_identities  = pinnable.blocks.map(&:block_identities).flatten
        identities        = block_identities.map(&:identity)

        ensure_relation(pinnable.owner.class.name.downcase.to_sym) << pinnable.owner

        ensure_relation(:pictures).concat           pinnable.pictures
        ensure_relation(:paragraphs).concat         pinnable.paragraphs
        ensure_relation(:blocks).concat             pinnable.blocks
        ensure_relation(:block_identities).concat   block_identities

        identities.each do |identity|
          ensure_relation(identity.class.name.downcase.to_sym) << identity
        end
      end
      
      ensure_relation(:posts).concat pinnables
    end

  end
end if should_include?(:pinnables)


# Render
#
@__relations.each do |key, values|
  partial_name = key.to_s.singularize
  json.set! key, values.uniq do |value|
    json.partial! partial_name, :"#{partial_name}" => value
  end
end
