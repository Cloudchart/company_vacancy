$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cloud_blueprint/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cloud_blueprint"
  s.version     = CloudBlueprint::VERSION
  s.authors     = ["Eugene Kovalev"]
  s.email       = ["seanchas@gmail.com"]
  s.homepage    = "http://cloudorgchart.com"
  s.summary     = "Summary of CloudBlueprint."
  s.description = "Description of CloudBlueprint."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
end
