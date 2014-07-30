module CloudProfile
  class PersonalSerializer < ActiveModel::Serializer

    #
    #
    class CompanySerializer < ActiveModel::Serializer
      attributes :uuid, :name, :url
      
      def url
        main_app.company_path(object)
      end
    end


    #
    #
    class PersonSerializer < ActiveModel::Serializer
      attributes :company_id, :occupation
    end


    #
    #
    class EmailSerializer < ActiveModel::Serializer
      attributes :uuid, :address
    end


    attributes :uuid, :full_name, :avatar_url, :url, :emails, :verification_tokens

    has_many :companies, serializer: CompanySerializer

    has_many :people, serializer: PersonSerializer
    

    def url
      user_path
    end
    

    def avatar_url
      object.avatar.url if object.avatar_stored?
    end
    

    def emails
      ActiveModel::ArraySerializer.new(object.emails.order(:created_at), each_serializer: EmailSerializer)
    end
    
    def verification_tokens
      ActiveModel::ArraySerializer.new(object.tokens.where(name: 'email_verification').order(:created_at), only: [:uuid, :data])
    end
    

  end
  
end
