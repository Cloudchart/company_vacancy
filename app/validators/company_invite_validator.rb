class CompanyInviteValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:email] = 'missing' if record.data[:email].blank?
    record.errors[:email] = 'taken'   if user_already_invited?(record)
  end
  
  private
  
  def user_already_invited?(record)
    email = CloudProfile::Email.includes(user: :companies).find_by(address: record.data[:email])
    ids   = email.try(:user).try(:companies).try(:map, &:uuid) || []
    ids.include?(record.owner_id)
  end
end
