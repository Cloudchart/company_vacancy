module CloudProfile
  class Engine < ::Rails::Engine
    isolate_namespace CloudProfile
    
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.path['db/migrate'].expand.each do |path|
          app.config.path['db/migrate'] << path
        end
      end
    end
    
  end
end
