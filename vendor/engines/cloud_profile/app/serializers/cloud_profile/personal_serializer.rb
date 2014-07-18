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


    attributes :uuid, :full_name, :avatar_url, :url

    has_many :companies, serializer: CompanySerializer

    has_many :people, serializer: PersonSerializer
    
    
    def url
      user_path
    end
    
    def avatar_url
      object.avatar.url if object.avatar_stored?
    end
    

  end
  
end
