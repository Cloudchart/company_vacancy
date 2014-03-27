module IndustriesHelper
  
  def industries_collection_for_select
    Industry.roots.includes(:children).inject([]) do |memo, record|
      memo.push [record.name, record.to_param]
      record.children.each { |child| memo.push ['- ' + child.name, child.to_param] }
      memo
    end
  end

end
