$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cloud_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cloud_api"
  s.version     = CloudApi::VERSION
  s.authors     = ["Eugene Kovalev"]
  s.email       = ["seanchas@insights.vc"]
  s.homepage    = "http://insights.vc"
  s.summary     = "Insights.VC API endpoint"
  s.description = "Insights.VC API endpoint"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
end
