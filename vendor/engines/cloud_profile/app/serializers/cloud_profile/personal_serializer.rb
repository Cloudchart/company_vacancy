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


    attributes :uuid, :first_name, :last_name, :url

    has_many :companies, serializer: CompanySerializer

    has_many :people, serializer: PersonSerializer
    
    
    def url
      user_path
    end
    

  end
  
end
