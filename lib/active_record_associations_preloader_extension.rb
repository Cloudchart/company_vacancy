module ActiveRecord
  module Associations
    class Preloader
      def preloader_for(reflection, owners, rhs_klass)
        return NullPreloader unless rhs_klass

        # if owners.first.association(reflection.name).loaded?
        #   return AlreadyLoaded
        # end

        if owners.all? { |owner| owner.association(reflection.name).loaded? }
          return AlreadyLoaded
        end

        case reflection.macro
        when :has_many
          reflection.options[:through] ? HasManyThrough : HasMany
        when :has_one
          reflection.options[:through] ? HasOneThrough : HasOne
        when :belongs_to
          BelongsTo
        end
      end
    end
  end
end
