module RailsAdmin
  module Extensions
    module PaperTrail
      class VersionProxy

        def username
          @user_class.find(@version.whodunnit).try(:email) rescue nil || @version.whodunnit
        end

      end
    end
  end
end
