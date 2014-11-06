# base
# 
json.company ams(@company, scope: current_user)
# json.blocks ams(@company.blocks)
json.blocks ams(blocks = Block.where(owner_id: @company.posts.ids << @company.id))
json.vacancies ams(@company.vacancies)
json.people ams(@company.people)
# json.pictures ams(@company.pictures)
json.pictures ams(Picture.where(owner_id: blocks.select{ |block| block.identity_type == 'Picture' }.map(&:id)))
# json.pictures ams(@company.paragraphs)
json.paragraphs ams(Paragraph.where(owner_id: blocks.select{ |block| block.identity_type == 'Paragraph' }.map(&:id)))
json.posts ams(@company.posts)

# invites
# 
if can?(:manage_company_invites, @company)
  json.users ams(@company.users)
  json.roles ams(@company.roles)
  json.tokens ams(@company.invite_tokens)
end
