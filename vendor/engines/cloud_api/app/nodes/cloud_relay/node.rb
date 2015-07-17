module CloudRelay

  class Node


    class << self


      def exposes(model_class)
        @exposes = model_class
      end


      def attributes(*names)
        @attributes ||= []

        names.each { |name| @attributes << name.to_sym }

        true
      end


      def connection(name, node_class)
        @connections ||= {}

        @connections[name.to_sym] = node_class

        true
      end

    end


  end

end
