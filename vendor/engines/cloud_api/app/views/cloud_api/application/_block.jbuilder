json.(block, :uuid)
json.(block, :owner_id, :owner_type, :identity_type, :kind)
json.(block, :is_locked, :position)
json.(block, :created_at, :updated_at)


json.identity_ids begin
  preload_associations(siblings, cache, :block_identities)

  block.identity_ids
end
