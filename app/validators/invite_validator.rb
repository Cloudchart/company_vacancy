class InviteValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:email] = 'missing' if record.data[:email].blank?
    record.errors[:email] = 'invalid' unless /.+@.+\..+/i.match(record.data[:email])
    record.errors[:email] = 'taken'   if user_already_exists?(record) || user_already_invited?(record)
  end
  
private
  
  def user_already_invited?(record)
    emails = record.owner.invite_tokens.map { |record| record.data[:email] }
    emails.include?(record.data[:email])
  end
  
  def user_already_exists?(record)
    owner_relation_name = record.owner_type.tableize.to_sym

    email = CloudProfile::Email.includes(user: owner_relation_name).find_by(address: record.data[:email])
    ids = email.try(:user).try(owner_relation_name).try(:map, &:id) || []
        
    ids.include?(record.owner_id)
  end
end
